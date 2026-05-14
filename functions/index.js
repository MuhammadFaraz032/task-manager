const { onDocumentUpdated, onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// ─────────────────────────────────────────────
// HELPER — send FCM + write notification doc
// ─────────────────────────────────────────────
async function sendNotification({ userId, type, taskId, taskTitle, message, triggeredBy, workspaceId }) {
  try {
    console.log(`sendNotification called — userId: ${userId}, type: ${type}, taskId: ${taskId}`);

    const userDoc = await db.collection("users").doc(userId).get();
    if (!userDoc.exists) {
      console.log(`User doc not found for userId: ${userId}`);
      return;
    }

    const fcmToken = userDoc.data().fcmToken;
    console.log(`fcmToken for ${userId}: ${fcmToken ? "EXISTS" : "NULL"}`);

    // Write to notifications collection
    await db
      .collection("notifications")
      .doc(userId)
      .collection("items")
      .add({
        type,
        taskId,
        taskTitle,
        message,
        triggeredBy,
        workspaceId: workspaceId ?? null,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    console.log(`Notification doc written for userId: ${userId}`);

    // Send FCM push if token exists
    if (fcmToken) {
      const result = await admin.messaging().send({
        token: fcmToken,
        notification: {
          title: getTitle(type),
          body: message,
        },
        data: {
          taskId: taskId ?? '',
          type: type ?? '',
          workspaceId: workspaceId ?? '',
        },
        android: {
          priority: "high",
          notification: {
            channelId: "task_manager_channel",
            priority: "high",
            defaultSound: true,
          },
        },
      });
      console.log(`FCM send result: ${result}`);
    } else {
      console.log(`No FCM token — skipping push for userId: ${userId}`);
    }
  } catch (error) {
    console.error("sendNotification error:", error);
  }
}

function getTitle(type) {
  switch (type) {
    case "task_assigned": return "New Task Assigned";
    case "task_completed": return "Task Completed";
    case "comment_added": return "New Comment";
    default: return "Task Manager";
  }
}

// ─────────────────────────────────────────────
// FUNCTION 1 — onTaskAssigned
// ─────────────────────────────────────────────
exports.onTaskAssigned = onDocumentUpdated("workspaces/{wId}/tasks/{taskId}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();

  console.log(`onTaskAssigned — before.assignedTo: ${before.assignedTo}, after.assignedTo: ${after.assignedTo}`);

  if (before.assignedTo === after.assignedTo) return null;
  if (!after.assignedTo) return null;
  if (after.assignedTo === after.createdBy) return null;

  await sendNotification({
    userId: after.assignedTo,
    type: "task_assigned",
    taskId: event.params.taskId,
    taskTitle: after.title,
    message: `You were assigned "${after.title}"`,
    triggeredBy: after.createdBy,
    workspaceId: event.params.wId,
  });

  return null;
});

// ─────────────────────────────────────────────
// FUNCTION 1B — onTaskCreatedWithAssignee
// ─────────────────────────────────────────────
exports.onTaskCreatedWithAssignee = onDocumentCreated("workspaces/{wId}/tasks/{taskId}", async (event) => {
  const after = event.data.data();

  if (!after.assignedTo) return null;
  if (after.assignedTo === after.createdBy) return null;

  await sendNotification({
    userId: after.assignedTo,
    type: "task_assigned",
    taskId: event.params.taskId,
    taskTitle: after.title,
    message: `You were assigned "${after.title}"`,
    triggeredBy: after.createdBy,
    workspaceId: event.params.wId,
  });

  return null;
});

// ─────────────────────────────────────────────
// FUNCTION 2 — onTaskCompleted
// ─────────────────────────────────────────────
exports.onTaskCompleted = onDocumentUpdated("workspaces/{wId}/tasks/{taskId}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();

  console.log(`onTaskCompleted — before.status: ${before.status}, after.status: ${after.status}`);

  if (before.status === after.status) return null;
  if (after.status !== "completed") return null;
  if (after.createdBy === after.assignedTo) return null;
  if (!after.createdBy) return null;

  await sendNotification({
    userId: after.createdBy,
    type: "task_completed",
    taskId: event.params.taskId,
    taskTitle: after.title,
    message: `"${after.title}" was marked as completed`,
    triggeredBy: after.assignedTo ?? after.createdBy,
    workspaceId: event.params.wId,
  });

  return null;
});

// ─────────────────────────────────────────────
// FUNCTION 3 — onCommentAdded
// ─────────────────────────────────────────────
exports.onCommentAdded = onDocumentCreated("workspaces/{wId}/tasks/{taskId}/comments/{commentId}", async (event) => {
  const comment = event.data.data();
  const taskId = event.params.taskId;
  const wId = event.params.wId;

  console.log(`onCommentAdded — taskId: ${taskId}, wId: ${wId}, commenter: ${comment.createdBy}`);

  const taskDoc = await db
    .collection("workspaces")
    .doc(wId)
    .collection("tasks")
    .doc(taskId)
    .get();

  if (!taskDoc.exists) {
    console.log(`Task doc not found — taskId: ${taskId}`);
    return null;
  }

  const task = taskDoc.data();
  const commenter = comment.createdBy;

  const toNotify = new Set();
  if (task.assignedTo && task.assignedTo !== commenter) {
    toNotify.add(task.assignedTo);
  }
  if (task.createdBy && task.createdBy !== commenter) {
    toNotify.add(task.createdBy);
  }

  console.log(`Notifying ${toNotify.size} users for comment`);

  const promises = Array.from(toNotify).map((userId) =>
    sendNotification({
      userId,
      type: "comment_added",
      taskId,
      taskTitle: task.title,
      message: `${comment.createdByName} commented on "${task.title}"`,
      triggeredBy: commenter,
      workspaceId: wId,
    }));

  await Promise.all(promises);
  return null;
});
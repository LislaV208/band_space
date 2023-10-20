/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// The Firebase Admin SDK to access Firestore.
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

initializeApp();

exports.updateDurationsFromSecondsToMiliseconds = onRequest(async (request, response) => {
    const writeBatch = getFirestore().batch();

    const versionsQuery = await getFirestore().collection("versions").get();
    versionsQuery.forEach((doc) => {
        var file = doc.get('file');
        const durationInS = file['duration'];
        const durationInMs = durationInS * 1000;

        file['duration'] = durationInMs;

        writeBatch.update(doc.ref, { 'file': file });
        logger.debug('Updated duration for version ${doc.id}');
    });
    var isSuccess = true;
    try {
        await writeBatch.commit();
        logger.info('Duration data updated successfuly');
    } catch (error) {
        isSuccess = false;
        logger.error('Unable to update duration data', error);
    }

    response.send(isSuccess ? 'Duration data updated successfuly' : 'Unable to update duration data');
});

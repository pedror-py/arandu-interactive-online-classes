import { initializeApp, getApp } from 'firebase/app'
import { getAuth, connectAuthEmulator } from 'firebase/auth'
import { getFirestore, enableIndexedDbPersistence, connectFirestoreEmulator } from 'firebase/firestore'
import { getStorage, ref } from "firebase/storage"
import { getAnalytics } from "firebase/analytics"
import { getPerformance } from "firebase/performance"
import { getFunctions, connectFunctionsEmulator } from 'firebase/functions'

const firebaseConfig = {
	apiKey: "AIzaSyDKiIeMazWW4F232WrY11DAVI18oyf863s",
	authDomain: "free-educ-app.firebaseapp.com",
	projectId: "free-educ-app",
	storageBucket: "free-educ-app.appspot.com",
	messagingSenderId: "624303785725",
	appId: "1:624303785725:web:3eaa94eedb690bc1506094",
	measurementId: "G-HVG59NPQRQ"
};
          
// # Initialize Firebase
const firebaseApp = initializeApp(firebaseConfig);

export const auth = getAuth(firebaseApp)
// # window.firestoreDB = getFirestore(firebaseApp)
export const firestoreDB = getFirestore(firebaseApp)
export const storage = getStorage(firebaseApp)
export const analytics = getAnalytics(firebaseApp)
export const performance = getPerformance(firebaseApp)
export const functions = getFunctions(firebaseApp)

connectFunctionsEmulator(functions, "localhost", 5001)
package com.example.code

import android.content.ContentValues.TAG
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import com.google.firebase.database.DataSnapshot
import com.google.firebase.database.DatabaseError
import com.google.firebase.database.ValueEventListener
import com.google.firebase.database.ktx.database
import com.google.firebase.database.ktx.getValue
import com.google.firebase.ktx.Firebase
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        appId("https://flutter-admob-getx-default-rtdb.firebaseio.com/");
    }

    private fun appId(url: String) {
        // Retrive instance of database and referance the
        //location you want to read/write.
        val database = Firebase.database(url);
        val myRef = database.getReference("appId");

        myRef.addValueEventListener(object : ValueEventListener {
            override fun onDataChange(dataSnapshot: DataSnapshot) {
                // This method is called once with the initial value and again
                // whenever data at this location is updated.
                val value = dataSnapshot.getValue<String>()
                Log.d(TAG, "Value is D: $value")

                try {
                    val ai: ApplicationInfo =  packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA);
                    val bundle: Bundle = ai.metaData
                    val myApiKey: String? =  bundle.getString("com.google.android.gms.ads.APPLICATION_ID")
                    Log.d(TAG, "ApiKey from Firebase: $myApiKey")
                    //Replace your key APPLICATION_ID here
                    ai.metaData.putString(
                        "com.google.android.gms.ads.APPLICATION_ID",
                        value,
                    )
                    val apiKey: String? =
                        bundle.getString("com.google.android.gms.ads.APPLICATION_ID")
                    Log.d(TAG, "Updated Api Key: $apiKey")
                } catch (e: PackageManager.NameNotFoundException) {
                    Log.e(
                        TAG,
                        "Failed to load meta-data, NameNotFound: $e"
                    )
                } catch (e: NullPointerException) {
                    Log.e(
                        TAG,
                        "Failed to load meta-data, NullPointer: " + e.message
                    )
                }
            }

            override fun onCancelled(error: DatabaseError) {
                // Failed to read value
                Log.w(TAG, "Failed to read value.", error.toException())
            }
        })
    }
}

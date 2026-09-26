package com.example.navigator_app

import android.app.Application
import com.yandex.mapkit.MapKitFactory

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        MapKitFactory.setApiKey("e50c42a7-9eca-426f-90d4-fe4b30d3c801")
    }
}

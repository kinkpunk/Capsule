# iOS Permissions and Setup

## Required Info.plist Keys
1. `NSCameraUsageDescription`  
   Example: "Camera access is needed to photograph your clothes."
2. `NSPhotoLibraryUsageDescription`  
   Example: "Photo library access is needed to import clothing photos."
3. `NSLocationWhenInUseUsageDescription`  
   Example: "Location is needed to fetch local weather for outfit recommendations."

## Why Each Permission Exists
1. Camera: capture new wardrobe items in-app.
2. Photo Library: import existing item images.
3. Location: request local weather to adjust outfit suggestions.

## Fallback Behavior
1. If camera is denied, user can still import from gallery.
2. If gallery is denied, user can still create items without photo.
3. If location is denied, app uses fallback weather range.

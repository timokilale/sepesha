# Sepesha App - Missing Backend Features

This document outlines the backend features that need to be implemented to support the full ride request flow in the Sepesha app.

## Missing API Endpoints

### [REQUEST] GET /api/drivers/available
- Purpose: Get a list of available online drivers near a specific location
- Parameters:
  - `latitude` (numeric, required): Current latitude
  - `longitude` (numeric, required): Current longitude
  - `radius` (numeric, optional): Search radius in kilometers (default: 5)
- Response: List of available drivers with their current locations, vehicle details, and ratings

### [REQUEST] POST /api/ride-request/upload-luggage-photo
- Purpose: Upload a luggage photo for a ride request
- Parameters:
  - `photo` (file, required): Luggage photo (jpg, jpeg, png, max 5MB)
  - `booking_id` (uuid, optional): Booking ID if the photo is being added to an existing booking
- Response: URL of the uploaded photo

### [REQUEST] PUT /api/ride-request/respond
- Purpose: Allow a driver to accept or reject a ride request
- Parameters:
  - `booking_id` (uuid, required): Booking ID
  - `driver_id` (uuid, required): Driver's auth_key
  - `response` (string, required): Either "accept" or "reject"
  - `reason` (string, optional): Reason for rejection
- Response: Updated booking details

### [REQUEST] GET /api/driver/location
- Purpose: Get the real-time location of a driver
- Parameters:
  - `driver_id` (uuid, required): Driver's auth_key
- Response: Driver's current latitude and longitude

### [REQUEST] PUT /api/driver/location
- Purpose: Update the driver's current location
- Parameters:
  - `driver_id` (uuid, required): Driver's auth_key
  - `latitude` (numeric, required): Current latitude
  - `longitude` (numeric, required): Current longitude
- Response: Success status

## Notification System Enhancements

### [REQUEST] Custom Notification Sounds
- Add support for custom notification sounds, specifically a "bip" sound for driver notifications
- Ensure the sound files are properly packaged with the app
- Update the FCM payload to include the custom sound reference

### [REQUEST] Enhanced Notification Payload
- Add support for including luggage photo URL in the notification payload
- Add support for including detailed pickup/dropoff information in the notification payload
- Add support for including vendor/customer details in the notification payload when applicable

## Test Drivers Configuration

### [REQUEST] Test Driver Accounts
- Create and maintain two always-online test driver accounts:
  - Username: zomgo
  - Username: steph
- These accounts should automatically accept ride requests for testing purposes
- They should appear on the map regardless of their actual location
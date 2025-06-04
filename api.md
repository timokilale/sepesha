# Sepesha API Documentation

This document provides comprehensive documentation for all API endpoints in the Sepesha application.

## Table of Contents

1. [Using the API in a Ride-Sharing App](#using-the-api-in-a-ride-sharing-app)
2. [Authentication](#authentication)
3. [User Management](#user-management)
4. [Profile Management](#profile-management)
5. [Vehicle Management](#vehicle-management)
6. [Booking Management](#booking-management)
7. [Notifications](#notifications)
8. [Support System](#support-system)
9. [Driver Reviews](#driver-reviews)
10. [Regions](#regions)
11. [Fee Categories](#fee-categories)
12. [Role-Specific Endpoints](#role-specific-endpoints)

## Using the API in a SEPESHA App

This section provides a comprehensive guide on how to integrate and use the Sepesha API in a ride-sharing application .

### Overview

The Sepesha API provides all the necessary endpoints to build a fully functional ride-sharing application. The API supports:

- User registration and authentication (for both riders and drivers)
- Vehicle management
- Ride booking and tracking
- Payment processing
- Driver ratings and reviews
- Support ticket system

### Getting Started

To integrate the Sepesha API into your application, follow these steps:

1. Set up your development environment
2. Configure API base URL in your application
3. Implement authentication flow
4. Build the core features of your ride-sharing app

### Authentication Flow

For a ride-sharing app, you'll need to implement one of the following authentication flows:

1. **User Registration**:
  - Riders register with `user_type: "customer"`
  - Drivers register with `user_type: "driver"` (requires additional documentation)

2. **Login Process (OTP-based)**:
  - Request OTP via the login endpoint
  - Verify OTP to receive access and refresh tokens
  - Store tokens securely in your application
  - Use refresh token to get new access tokens when needed

3. **OAuth2 Authentication** (Alternative):
  - Redirect users to OAuth2 provider (Google, Facebook, or GitHub)
  - Handle the callback from the provider
  - Receive access and refresh tokens
  - Store tokens securely in your application

#### Example: User Registration (Driver)

```swift
// Swift example
import Alamofire

let parameters: [String: Any] = [
    "first_name": "John",
    "middle_name": "Doe",
    "last_name": "Smith",
    "region_id": 1,
    "phonecode": "255",
    "email": "john@example.com",
    "user_type": "driver",
    "password": "securepassword",
    "password_confirmation": "securepassword",
    "phone": "123456789",
    "privacy_checked": true,
    "licence_number": "DL12345678",
    "licence_expiry": "2025-12-31"
]

// Add profile photo and license attachment
let profilePhoto = UIImage(named: "profile.jpg")!.jpegData(compressionQuality: 0.8)!
let licenseDoc = // document data

AF.upload(multipartFormData: { multipartFormData in
    // Add parameters
    for (key, value) in parameters {
        if let temp = value as? String {
            multipartFormData.append(temp.data(using: .utf8)!, withName: key)
        }
        if let temp = value as? Int {
            multipartFormData.append("\(temp)".data(using: .utf8)!, withName: key)
        }
        if let temp = value as? Bool {
            multipartFormData.append("\(temp)".data(using: .utf8)!, withName: key)
        }
    }

    // Add files
    multipartFormData.append(profilePhoto, withName: "profile_photo", fileName: "profile.jpg", mimeType: "image/jpeg")
    multipartFormData.append(licenseDoc, withName: "attachment", fileName: "license.pdf", mimeType: "application/pdf")

}, to: "https://api.example.com/api/register")
.responseJSON { response in
    // Handle response
}
```

#### Example: Login and OTP Verification

```javascript
// JavaScript example
// Step 1: Request OTP
async function requestOTP(phone, userType) {
  try {
    const response = await fetch('https://api.example.com/api/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        phone: phone,
        user_type: userType
      })
    });

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error requesting OTP:', error);
  }
}

// Step 2: Verify OTP
async function verifyOTP(phone, otp, userType) {
  try {
    const response = await fetch('https://api.example.com/api/verify-otp', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        phone: phone,
        otp: otp,
        user_type: userType
      })
    });

    const data = await response.json();

    if (data.status) {
      // Store tokens
      localStorage.setItem('access_token', data.access_token);
      localStorage.setItem('refresh_token', data.refresh_token);
      localStorage.setItem('uid', data.uid);
    }

    return data;
  } catch (error) {
    console.error('Error verifying OTP:', error);
  }
}
```

#### Example: OAuth2 Authentication

```javascript
// JavaScript example for OAuth2 authentication
// Step 1: Redirect to OAuth2 provider
function redirectToOAuth2Provider(provider) {
  // provider can be 'google', 'facebook', or 'github'
  fetch(`https://api.example.com/api/oauth2/${provider}`)
    .then(response => response.json())
    .then(data => {
      if (data.status && data.data.auth_url) {
        // Redirect user to the OAuth2 provider's authentication page
        window.location.href = data.data.auth_url;
      } else {
        console.error('Failed to get OAuth2 authorization URL');
      }
    })
    .catch(error => {
      console.error('Error redirecting to OAuth2 provider:', error);
    });
}

// Step 2: Handle OAuth2 callback
// This function would be called by the page that handles the OAuth2 callback URL
async function handleOAuth2Callback(provider, code) {
  try {
    // The code parameter is automatically added to the callback URL by the OAuth2 provider
    const callbackUrl = `https://api.example.com/api/oauth2/${provider}/callback?code=${code}`;

    const response = await fetch(callbackUrl);
    const data = await response.json();

    if (data.status) {
      // Store tokens
      localStorage.setItem('access_token', data.access_token);
      localStorage.setItem('refresh_token', data.refresh_token);
      localStorage.setItem('uid', data.uid);

      return data;
    } else {
      throw new Error(data.message || 'OAuth2 authentication failed');
    }
  } catch (error) {
    console.error('Error handling OAuth2 callback:', error);
    throw error;
  }
}

// Example usage
document.getElementById('google-login-btn').addEventListener('click', () => {
  redirectToOAuth2Provider('google');
});

document.getElementById('facebook-login-btn').addEventListener('click', () => {
  redirectToOAuth2Provider('facebook');
});

document.getElementById('github-login-btn').addEventListener('click', () => {
  redirectToOAuth2Provider('github');
});
```

### Core Workflows

#### 1. Driver Onboarding

For driver onboarding, implement the following workflow:

1. Register driver account
2. Verify phone number with OTP
3. Complete driver profile
4. Register vehicle details
5. Submit required documents
6. Wait for verification (driver's `is_verified` will be set to 1 when approved)

```kotlin
// Kotlin example for vehicle registration
fun registerVehicle(driverId: String, token: String) {
    val requestBody = MultipartBody.Builder()
        .setType(MultipartBody.FORM)
        .addFormDataPart("plate_number", "T123ABC")
        .addFormDataPart("make", "Toyota")
        .addFormDataPart("model", "Corolla")
        .addFormDataPart("year", "2020")
        .addFormDataPart("color", "White")
        .addFormDataPart("created_by", userId)
        .addFormDataPart("driver_id", driverId)
        .addFormDataPart("fee_category_id", feeCategoryId)
        .addFormDataPart("owner_id", driverId)
        .addFormDataPart("attachments[0][id]", "1")

    // Add vehicle registration document
    val file = File(filePath)
    val mediaType = "image/jpeg".toMediaTypeOrNull()
    requestBody.addFormDataPart(
        "attachments[0][attachment]",
        file.name,
        RequestBody.create(mediaType, file)
    )

    val request = Request.Builder()
        .url("https://api.example.com/api/vehicle")
        .post(requestBody.build())
        .addHeader("Authorization", "Bearer $token")
        .build()

    client.newCall(request).enqueue(object : Callback {
        // Handle response
    })
}
```

#### 2. Booking a Ride (Customer Perspective)

For customers booking a ride, implement this workflow:

1. Get available fee categories
2. Calculate ride distance and cost
3. Create booking request
4. Wait for driver assignment
5. Track ride status
6. Complete ride and leave review

```dart
// Dart/Flutter example for creating a booking
Future<void> createBooking() async {
  try {
    final response = await http.post(
      Uri.parse('https://api.example.com/api/request-ride'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'customer_id': customerId,
        'fee_category_id': feeCategoryId,
        'recepient_name': userName,
        'recepient_phone': userPhone,
        'user_type': 'customer',
        'description': 'Ride to downtown',
        'pickup_location': 'Current Location',
        'delivery_location': 'Downtown Mall',
        'pickup_date': DateTime.now().toIso8601String(),
        'pickup_latitude': currentLatitude,
        'pickup_longitude': currentLongitude,
        'delivery_latitude': destinationLatitude,
        'delivery_longitude': destinationLongitude,
        'distance_km': calculatedDistance,
      }),
    );

    final data = jsonDecode(response.body);
    if (data['status']) {
      // Store booking reference for tracking
      final bookingReference = data['data']['booking_reference'];
      // Implement UI to show booking status
    }
  } catch (e) {
    print('Error creating booking: $e');
  }
}
```

#### 3. Accepting and Managing Rides (Driver Perspective)

For drivers accepting and managing rides:

1. Retrieve available bookings
2. Accept a booking
3. Update ride status (assigned → intransit → completed)
4. Complete the ride

```javascript
// JavaScript example for updating booking status
async function updateBookingStatus(bookingId, driverId, vehicleId, status) {
  try {
    const response = await fetch(`https://api.example.com/api/update-ride/${bookingId}`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        driver_id: driverId,
        vehicle_id: vehicleId,
        status: status // "assigned", "intransit", or "completed"
      })
    });

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error updating booking status:', error);
  }
}
```

#### 4. Rating and Reviews

After ride completion, prompt customers to rate their driver:

```swift
// Swift example for submitting driver review
func submitDriverReview(driverId: String, rating: Int, review: String) {
    let parameters: [String: Any] = [
        "driver_id": driverId,
        "rating": rating,
        "review": review
    ]

    AF.request("https://api.example.com/api/driver-rating/create", 
               method: .post, 
               parameters: parameters, 
               encoding: JSONEncoding.default, 
               headers: ["Authorization": "Bearer \(accessToken)"])
        .responseJSON { response in
            // Handle response
        }
}
```

### Real-time Updates

For real-time updates on ride status, you can implement polling or use the socket functionality:

```javascript
// JavaScript example for socket connection
function connectToSocket() {
  // Connect to socket server
  const socket = new WebSocket('wss://socket.example.com');

  socket.onopen = function(e) {
    console.log("Socket connection established");
  };

  socket.onmessage = function(event) {
    const data = JSON.parse(event.data);

    // Handle different event types
    switch(data.event) {
      case 'booking_status_changed':
        updateBookingUI(data.booking);
        break;
      case 'driver_location_updated':
        updateDriverLocationOnMap(data.location);
        break;
      // Handle other events
    }
  };

  socket.onerror = function(error) {
    console.error(`Socket error: ${error.message}`);
  };

  return socket;
}
```

### Error Handling

Implement proper error handling for API requests:

```javascript
// JavaScript example for error handling
async function makeApiRequest(endpoint, method, body) {
  try {
    const response = await fetch(`https://api.example.com/api/${endpoint}`, {
      method: method,
      headers: {
        'Authorization': `Bearer ${getAccessToken()}`,
        'Content-Type': 'application/json'
      },
      body: body ? JSON.stringify(body) : undefined
    });

    const data = await response.json();

    if (!data.status) {
      // Handle API error
      handleApiError(data);
      return null;
    }

    return data;
  } catch (error) {
    // Handle network error
    handleNetworkError(error);
    return null;
  }
}

function handleApiError(errorData) {
  // Check for token expiration
  if (errorData.code === 401) {
    // Refresh token or redirect to login
    refreshTokenAndRetry();
  } else {
    // Display appropriate error message
    showErrorMessage(errorData.message);
  }
}

function handleNetworkError(error) {
  // Handle offline state
  if (!navigator.onLine) {
    showOfflineMessage();
  } else {
    // Handle other network errors
    showErrorMessage("Network error. Please try again.");
  }
}
```

### Best Practices

1. **Security**:
  - Store tokens securely (use Keychain for iOS, Encrypted SharedPreferences for Android)
  - Implement token refresh mechanism
  - Never store sensitive user information in local storage

2. **Performance**:
  - Implement caching for frequently accessed data
  - Use pagination for listing endpoints
  - Optimize network requests

3. **User Experience**:
  - Implement offline mode for essential features
  - Show loading indicators during API calls
  - Provide clear error messages

4. **Testing**:
  - Test API integration with different network conditions
  - Implement unit tests for API service classes
  - Test edge cases (token expiration, server errors)

### Conclusion

By following this guide, you can successfully integrate the Sepesha API into your ride-sharing application. The API provides all the necessary endpoints to build a robust and feature-rich application similar to Uber.

## Authentication

### Register User

Creates a new user account.

- **URL**: `/api/register`
- **Method**: `POST`
- **Authentication**: None
- **Parameters**:
  - `first_name` (string, required): User's first name
  - `middle_name` (string, optional): User's middle name
  - `last_name` (string, required): User's last name
  - `region_id` (numeric, required): User's region ID
  - `phonecode` (string, required): Must be "255" (Tanzania)
  - `email` (string, required): User's email address
  - `referal_code` (string, optional): Referral code
  - `user_type` (string, required): One of "driver", "vendor", "agent", "customer"
  - `business_description` (string, required for vendors): Description of business
  - `profile_photo` (file, required for drivers): Profile photo (jpg, jpeg, png, max 2MB)
  - `attachment` (file, required for drivers): ID or license document (jpg, jpeg, png, pdf, max 2MB)
  - `password` (string, required): Password (min 6 characters)
  - `password_confirmation` (string, required): Must match password
  - `phone` (numeric, required): 9-digit phone number (without country code)
  - `privacy_checked` (boolean, required): Must be accepted
  - `licence_number` (string, required for drivers): Driver's license number
  - `licence_expiry` (date, required for drivers): License expiry date (must be future date)

- **Response**:
  ```json
  {
    "status": true,
    "message": "Registration successful.",
    "data": {
      "first_name": "John",
      "middle_name": "Doe",
      "last_name": "Smith",
      "phonecode": "255",
      "phone_number": "123456789",
      "email": "john@example.com",
      "profile_photo": "https://example.com/storage/documents/123456_abcdef.jpg",
      "attachment": "https://example.com/storage/documents/123456_ghijkl.pdf",
      "user_type": "driver",
      "is_verified": 0,
      "uid": "uuid-string",
      "otp": "1234",
      "otp_expires_at": "2023-05-17 15:30:00"
    }
  }
  ```

### Login

Initiates login process by sending OTP.

- **URL**: `/api/login`
- **Method**: `POST`
- **Authentication**: None
- **Parameters**:
  - `phone` (integer, required): User's phone number
  - `user_type` (string, required): One of "driver", "vendor", "agent", "customer"

- **Response**:
  ```json
  {
    "status": true,
    "message": "OPT Created successfully",
    "data": {
      "phone_number": "123456789",
      "user_type": "driver",
      "otp": "1234",
      "is_verified": 1,
      "otp_expires_at": "2023-05-17 15:30:00"
    }
  }
  ```

### Verify OTP

Verifies OTP and returns access token.

- **URL**: `/api/verify-otp`
- **Method**: `POST`
- **Authentication**: None
- **Parameters**:
  - `phone` (integer, required): User's phone number
  - `otp` (string, required): 4-digit OTP code
  - `user_type` (string, required): One of "driver", "vendor", "agent", "customer"

- **Response**:
  ```json
  {
    "status": true,
    "message": "OTP verified successfully",
    "is_verified": 1,
    "access_token": "jwt-token-string",
    "refresh_token": "refresh-token-string",
    "uid": "uuid-string"
  }
  ```

### Resend OTP

Resends OTP for verification.

- **URL**: `/api/resend-otp`
- **Method**: `POST`
- **Authentication**: None
- **Parameters**:
  - `phone` (integer, required): User's phone number
  - `user_type` (string, required): One of "driver", "vendor", "agent", "customer"

- **Response**:
  ```json
  {
    "status": true,
    "message": "OPT Created successfully",
    "data": {
      "phone_number": "123456789",
      "user_type": "driver",
      "otp": "1234",
      "is_verified": 1,
      "otp_expires_at": "2023-05-17 15:30:00"
    }
  }
  ```

### Refresh Token

Refreshes access token using refresh token.

- **URL**: `/api/refresh`
- **Method**: `POST`
- **Authentication**: None
- **Parameters**:
  - `refresh_token` (string, required): Refresh token
  - `user_type` (string, required): One of "driver", "vendor", "agent", "customer"

- **Response**:
  ```json
  {
    "access_token": "new-jwt-token-string"
  }
  ```

### Logout

Logs out user by invalidating refresh token.

- **URL**: `/api/logout`
- **Method**: `POST`
- **Authentication**: None
- **Parameters**:
  - `refresh_token` (string, required): Refresh token

- **Response**:
  ```json
  {
    "status": true,
    "message": "Logged out successfully",
    "code": 200
  }
  ```

### OAuth2 Authentication

#### Redirect to OAuth2 Provider

Redirects the user to the specified OAuth2 provider's authentication page.

- **URL**: `/api/oauth2/{provider}`
- **Method**: `GET`
- **Authentication**: None
- **URL Parameters**:
  - `provider` (string, required): OAuth2 provider name. Valid values: "google", "facebook", "github"

- **Response**:
  ```json
  {
    "status": true,
    "message": "OAuth2 authorization URL",
    "data": {
      "auth_url": "https://accounts.google.com/o/oauth2/v2/auth?client_id=..."
    }
  }
  ```

#### OAuth2 Callback

Handles the callback from the OAuth2 provider and authenticates the user.

- **URL**: `/api/oauth2/{provider}/callback`
- **Method**: `GET`
- **Authentication**: None
- **URL Parameters**:
  - `provider` (string, required): OAuth2 provider name. Valid values: "google", "facebook", "github"
- **Query Parameters**:
  - `code` (string, required): Authorization code from the OAuth2 provider

- **Response**:
  ```json
  {
    "status": true,
    "message": "OAuth2 authentication successful",
    "is_verified": 1,
    "access_token": "jwt-token-string",
    "refresh_token": "refresh-token-string",
    "uid": "uuid-string"
  }
  ```

## User Management

### Get User

Retrieves user information.

- **URL**: `/api/user/{id}`
- **Method**: `GET`
- **Authentication**: JWT (any role)
- **Parameters**: None

- **Response**:
  ```json
  {
    "status": true,
    "message": "data found",
    "code": 200,
    "data": {
      "name": "John",
      "mname": "Doe",
      "sname": "Smith",
      "email": "john@example.com",
      "phone": "123456789",
      "profile_photo": "https://example.com/storage/documents/123456_abcdef.jpg",
      "role": "driver"
    }
  }
  ```

### Update User Profile

Updates user profile information.

- **URL**: `/api/user/update-profile/{id}`
- **Method**: `POST`
- **Authentication**: JWT (any role)
- **Parameters**:
  - `first_name` (string, required): User's first name
  - `middle_name` (string, optional): User's middle name
  - `last_name` (string, required): User's last name
  - `region_id` (numeric, required): User's region ID
  - `phonecode` (string, required): Must be "255" (Tanzania)
  - `email` (string, optional): User's email address
  - `business_description` (string, required for vendors): Description of business
  - `profile_photo` (file, optional): Profile photo (jpg, jpeg, png, max 2MB)
  - `attachment` (file, optional): ID or license document (jpg, jpeg, png, pdf, max 2MB)
  - `phone` (numeric, required): 9-digit phone number (without country code)

- **Response**:
  ```json
  {
    "status": true,
    "message": "User profile updated successfully",
    "data": {
      "name": "John",
      "mname": "Doe",
      "sname": "Smith",
      "email": "john@example.com",
      "phone": "123456789",
      "profile_photo": "https://example.com/storage/documents/123456_abcdef.jpg"
    }
  }
  ```

## Profile Management

### Get User Profile

Retrieves the authenticated user's profile information.

- **URL**: `/api/user/profile`
- **Method**: `GET`
- **Authentication**: JWT (any role)
- **Parameters**: None

- **Response**:
  ```json
  {
    "status": true,
    "message": "Profile retrieved successfully",
    "data": {
      "id": "uuid-string",
      "first_name": "John",
      "middle_name": "Doe",
      "last_name": "Smith",
      "email": "john@example.com",
      "phone": "123456789",
      "phonecode": "255",
      "profile_photo": "https://example.com/storage/images/123456_abcdef.jpg",
      "user_type": "driver",
      "region_id": 1,
      "business_description": null,
      "documents": {
        "attachment": "https://example.com/storage/documents/123456_ghijkl.pdf",
        "driver_license_number": "DL12345678",
        "license_expiry_date": "2025-12-31"
      },
      "created_at": "2023-05-17T15:30:00",
      "updated_at": "2023-05-17T16:30:00"
    }
  }
  ```

### Update User Profile

Updates the authenticated user's profile information.

- **URL**: `/api/user/profile`
- **Method**: `PUT`
- **Authentication**: JWT (any role)
- **Parameters**:
  - `first_name` (string, optional): User's first name
  - `middle_name` (string, optional): User's middle name
  - `last_name` (string, optional): User's last name
  - `email` (string, optional): User's email address
  - `phone` (numeric, optional): 9-digit phone number (without country code)
  - `region_id` (numeric, optional): User's region ID
  - `business_description` (string, optional): Description of business (for vendors)
  - `profile_photo` (file, optional): Profile photo (jpg, jpeg, png, max 2MB)
  - `attachment` (file, optional): ID or license document (pdf only, max 2MB)

- **Response**:
  ```json
  {
    "status": true,
    "message": "Profile updated successfully",
    "data": {
      "id": "uuid-string",
      "first_name": "John",
      "middle_name": "Doe",
      "last_name": "Smith",
      "email": "john@example.com",
      "phone": "123456789",
      "phonecode": "255",
      "profile_photo": "https://example.com/storage/images/123456_abcdef.jpg",
      "user_type": "driver",
      "region_id": 1,
      "business_description": null,
      "documents": {
        "attachment": "https://example.com/storage/documents/123456_ghijkl.pdf",
        "driver_license_number": "DL12345678",
        "license_expiry_date": "2025-12-31"
      },
      "updated_at": "2023-05-17T16:30:00"
    }
  }
  ```

### Update FCM Token

Updates the user's Firebase Cloud Messaging token for push notifications.

- **URL**: `/api/user/fcm-token`
- **Method**: `POST`
- **Authentication**: JWT (any role)
- **Parameters**:
  - `fcm_token` (string, required): Firebase Cloud Messaging token

- **Response**:
  ```json
  {
    "status": true,
    "message": "FCM token updated successfully"
  }
  ```

## Vehicle Management

### Create Vehicle

Registers a new vehicle.

- **URL**: `/api/vehicle`
- **Method**: `POST`
- **Authentication**: JWT (any role)
- **Parameters**:
  - `plate_number` (string, required): Vehicle plate number (format: T123ABC or MC123ABC)
  - `make` (string, required): Vehicle make/manufacturer
  - `model` (string, required): Vehicle model
  - `year` (string, required): Manufacturing year (4 digits)
  - `color` (string, optional): Vehicle color
  - `weight` (numeric, optional): Vehicle weight
  - `capacity` (integer, optional): Vehicle capacity
  - `longitude` (string, optional): Current longitude
  - `latitude` (string, optional): Current latitude
  - `created_by` (integer, required): User ID of creator
  - `driver_id` (uuid, required): Driver's auth_key
  - `fee_category_id` (uuid, required): Fee category ID
  - `owner_id` (uuid, required): Vehicle owner's auth_key
  - `attachments` (array, required): Array of attachments
    - `id` (integer, required): Document type ID
    - `attachment` (file, required): Document file (jpg, jpeg, png, pdf, max 2MB)

- **Response**:
  ```json
  {
    "status": true,
    "message": "Vehicle created successfully.",
    "data": {
      "id": "uuid-string",
      "plate_number": "T123ABC",
      "make": "Toyota",
      "model": "Corolla",
      "year": "2020",
      "color": "White",
      "status": "N",
      "category": {
        "id": "uuid-string",
        "name": "Sedan"
      },
      "attachments": [
        {
          "id": 1,
          "attachment": "https://example.com/storage/attachments/123456_abcdef.jpg",
          "name": "Vehicle Registration"
        }
      ]
    }
  }
  ```

### Update Vehicle

Updates vehicle information.

- **URL**: `/api/vehicle/{id}`
- **Method**: `PUT`
- **Authentication**: JWT (any role)
- **Parameters**:
  - `plate_number` (string, required): Vehicle plate number (format: T123ABC or MC123ABC)
  - `make` (string, required): Vehicle make/manufacturer
  - `model` (string, required): Vehicle model
  - `year` (string, required): Manufacturing year (4 digits)
  - `color` (string, optional): Vehicle color
  - `weight` (numeric, optional): Vehicle weight
  - `capacity` (integer, optional): Vehicle capacity
  - `longitude` (string, optional): Current longitude
  - `latitude` (string, optional): Current latitude
  - `owner_id` (uuid, required): Vehicle owner's auth_key
  - `driver_id` (uuid, required): Driver's auth_key
  - `fee_category_id` (integer, required): Fee category ID
  - `status` (string, optional): Vehicle status
  - `updated_by` (integer, required): User ID of updater

- **Response**:
  ```json
  {
    "status": true,
    "message": "Vehicle updated successfully.",
    "data": {
      "id": "uuid-string",
      "plate_number": "T123ABC",
      "make": "Toyota",
      "model": "Corolla",
      "year": "2020"
    }
  }
  ```

### Get Vehicle

Retrieves vehicle information by ID.

- **URL**: `/api/vehicle/{id}`
- **Method**: `GET`
- **Authentication**: JWT (any role)
- **Parameters**: None

- **Response**:
  ```json
  {
    "status": true,
    "message": "data found",
    "code": 200,
    "data": {
      "id": "uuid-string",
      "plate_number": "T123ABC",
      "make": "Toyota",
      "model": "Corolla",
      "year": "2020",
      "category": {
        "id": "uuid-string",
        "name": "Sedan"
      },
      "attachments": [
        {
          "id": 1,
          "attachment": "https://example.com/storage/attachments/123456_abcdef.jpg",
          "name": "Vehicle Registration"
        }
      ]
    }
  }
  ```

### Get Vehicle by Driver

Retrieves vehicle information by driver ID.

- **URL**: `/api/vehicle/driver/{id}`
- **Method**: `GET`
- **Authentication**: JWT (any role)
- **Parameters**: None

- **Response**:
  ```json
  {
    "status": true,
    "message": "data found",
    "code": 200,
    "data": {
      "id": "uuid-string",
      "plate_number": "T123ABC",
      "make": "Toyota",
      "model": "Corolla",
      "year": "2020",
      "category": {
        "id": "uuid-string",
        "name": "Sedan"
      },
      "attachments": [
        {
          "id": 1,
          "attachment": "https://example.com/storage/attachments/123456_abcdef.jpg",
          "name": "Vehicle Registration"
        }
      ]
    }
  }
  ```

### Get All Vehicles

Retrieves all vehicles.

- **URL**: `/api/vehicles`
- **Method**: `GET`
- **Authentication**: JWT (any role)
- **Parameters**: None

- **Response**:
  ```json
  {
    "status": true,
    "message": "data found",
    "code": 200,
    "data": [
      {
        "id": "uuid-string",
        "plate_number": "T123ABC",
        "make": "Toyota",
        "model": "Corolla",
        "year": "2020",
        "category": {
          "id": "uuid-string",
          "name": "Sedan"
        },
        "attachments": [
          {
            "id": 1,
            "attachment": "https://example.com/storage/attachments/123456_abcdef.jpg",
            "name": "Vehicle Registration"
          }
        ]
      }
    ]
  }
  ```

## Booking Management

### Create Booking

Creates a new ride/delivery booking.

- **URL**: `/api/request-ride`
- **Method**: `POST`
- **Authentication**: JWT (any role)
- **Parameters**:
  - `customer_id` (uuid, required): Customer's auth_key
  - `fee_category_id` (uuid, required): Fee category ID
  - `pickup_photo` (file, optional): Photo of item to be picked up (jpg, jpeg, png, max 2MB)
  - `discount_code` (string, optional): Discount code
  - `referal_code` (string, optional): Referral code
  - `recepient_name` (string, required): Recipient's name
  - `recepient_phone` (string, required): Recipient's phone number
  - `recepient_address` (string, optional): Recipient's address
  - `user_type` (string, required): Either "vendor" or "customer"
  - `customerDetails` (object, required when user_type is "vendor"): Customer details when vendor is requesting on behalf of a customer
    - `name` (string, required): Customer's name
    - `phone` (string, required): Customer's phone number
    - `address` (string, required): Customer's address
  - `description` (string, required): Booking description
  - `pickup_location` (string, required): Pickup location description
  - `delivery_location` (string, required): Delivery location description
  - `pickup_date` (datetime, required): Pickup date and time (format: Y-m-d\TH:i:s)
  - `pickup_latitude` (numeric, required): Pickup latitude
  - `pickup_longitude` (numeric, required): Pickup longitude
  - `delivery_latitude` (numeric, required): Delivery latitude
  - `delivery_longitude` (numeric, required): Delivery longitude
  - `distance_km` (numeric, required): Distance in kilometers

- **Response**:
  ```json
  {
    "status": true,
    "message": "Booking created successfully.",
    "data": {
      "id": "uuid-string",
      "booking_reference": "SPS1234567890",
      "customer_id": "uuid-string",
      "fee_category_id": "uuid-string",
      "pickup_location": "123 Main St",
      "delivery_location": "456 Elm St",
      "pickup_date": "2023-05-17T15:30:00",
      "status": "pending",
      "amount": 15000,
      "category": {
        "id": "uuid-string",
        "name": "Standard Delivery"
      },
      "customer": {
        "auth_key": "uuid-string",
        "name": "John",
        "sname": "Smith"
      }
    }
  }
  ```

### Update Booking

Updates a booking (assign driver, change status).

- **URL**: `/api/update-ride/{id}`
- **Method**: `PUT`
- **Authentication**: JWT (any role)
- **Parameters**:
  - `status` (string, required): One of "pending", "assigned", "accepted", "started", "intransit", "completed"
  - `driver_id` (uuid, required only when status is "assigned" or "accepted"): Driver's auth_key
  - `vehicle_id` (uuid, required only when status is "assigned" or "accepted"): Vehicle ID

- **Response**:
  ```json
  {
    "status": true,
    "message": "Ride status updated successfully.",
    "data": {
      "id": "uuid-string",
      "booking_reference": "SPS1234567890",
      "status": "assigned",
      "driver_id": "uuid-string",
      "driver_assignment_id": "uuid-string"
    }
  }
  ```

### Cancel Booking

Cancels a booking.

- **URL**: `/api/cancel-ride/{id}`
- **Method**: `POST`
- **Authentication**: JWT (any role)
- **Parameters**:
  - `cancel_reason` (string, required): Reason for cancellation
  - `cancel_by` (uuid, optional): User ID of the person cancelling the booking (defaults to authenticated user)

- **Response**:
  ```json
  {
    "status": true,
    "message": "Ride cancelled successfully.",
    "data": {
      "id": "uuid-string",
      "booking_reference": "SPS1234567890",
      "status": "cancelled",
      "cancel_reason": "Customer requested cancellation",
      "cancelled_at": "2023-05-17T16:30:00"
    }
  }
  ```

### Get All Bookings

Retrieves bookings with optional filtering.

- **URL**: `/api/bookings`
- **Method**: `GET`
- **Authentication**: JWT (any role)
- **Parameters**:
  - `userId` (uuid, optional): Filter bookings by user ID (can be customer, vendor, or driver)
  - `date` (date, optional): Filter bookings by date (format: Y-m-d)
  - `status` (string, optional): Filter bookings by status (one of "pending", "assigned", "accepted", "started", "intransit", "completed", "cancelled")
  - `userType` (string, optional): Filter by user type when userId is provided (one of "customer", "vendor", "driver")

- **Response**:
  ```json
  {
    "status": true,
    "message": "Bookings found",
    "code": 200,
    "data": [
      {
        "id": "uuid-string",
        "booking_reference": "SPS1234567890",
        "customer_id": "uuid-string",
        "vendor_id": "uuid-string",
        "driver_id": "uuid-string",
        "fee_category_id": "uuid-string",
        "pickup_location": "123 Main St",
        "delivery_location": "456 Elm St",
        "pickup_date": "2023-05-17T15:30:00",
        "status": "pending",
        "amount": 15000,
        "category": {
          "id": "uuid-string",
          "name": "Standard Delivery"
        },
        "customer": {
          "auth_key": "uuid-string",
          "name": "John",
          "sname": "Smith"
        },
        "driver": {
          "auth_key": "uuid-string",
          "name": "Jane",
          "sname": "Doe"
        },
        "vendor": {
          "auth_key": "uuid-string",
          "name": "Acme",
          "sname": "Corp"
        }
      }
    ]
  }
  ```

### Get Booking by ID

Retrieves a specific booking by ID.

- **URL**: `/api/booking/{id}`
- **Method**: `GET`
- **Authentication**: JWT (any role)
- **Parameters**: None

- **Response**:
  ```json
  {
    "status": true,
    "message": "data found",
    "code": 200,
    "data": {
      "id": "uuid-string",
      "booking_reference": "SPS1234567890",
      "customer_id": "uuid-string",
      "fee_category_id": "uuid-string",
      "pickup_location": "123 Main St",
      "delivery_location": "456 Elm St",
      "pickup_date": "2023-05-17T15:30:00",
      "status": "pending",
      "amount": 15000,
      "category": {
        "id": "uuid-string",
        "name": "Standard Delivery"
      },
      "customer": {
        "auth_key": "uuid-string",
        "name": "John",
        "sname": "Smith"
      }
    }
  }
  ```

### Get Customer/Vendor Bookings

Retrieves bookings for a specific customer/vendor filtered by status.

- **URL**: `/api/booking/get-customer-vendor-bookings`
- **Method**: `GET`
- **Authentication**: JWT (any role)
- **Parameters**:
  - `customer_id` (uuid, required): Customer's auth_key
  - `status` (string, required): One of "pending", "assigned", "intransit", "completed", "cancelled"

- **Response**:
  ```json
  {
    "status": true,
    "message": "data found",
    "code": 200,
    "data": [
      {
        "id": "uuid-string",
        "booking_reference": "SPS1234567890",
        "customer_id": "uuid-string",
        "fee_category_id": "uuid-string",
        "pickup_location": "123 Main St",
        "delivery_location": "456 Elm St",
        "pickup_date": "2023-05-17T15:30:00",
        "status": "pending",
        "amount": 15000,
        "category": {
          "id": "uuid-string",
          "name": "Standard Delivery"
        },
        "customer": {
          "auth_key": "uuid-string",
          "name": "John",
          "sname": "Smith"
        }
      }
    ]
  }
  ```

### Get Driver Bookings

Retrieves bookings assigned to a specific driver.

- **URL**: `/api/booking/get-driver-bookings`
- **Method**: `GET`
- **Authentication**: JWT (any role)
- **Parameters**:
  - `driver_id` (uuid, required): Driver's auth_key

- **Response**:
  ```json
  {
    "status": true,
    "message": "data found",
    "code": 200,
    "data": [
      {
        "id": "uuid-string",
        "booking_reference": "SPS1234567890",
        "customer_id": "uuid-string",
        "driver_id": "uuid-string",
        "fee_category_id": "uuid-string",
        "pickup_location": "123 Main St",
        "delivery_location": "456 Elm St",
        "pickup_date": "2023-05-17T15:30:00",
        "status": "assigned",
        "amount": 15000,
        "category": {
          "id": "uuid-string",
          "name": "Standard Delivery"
        },
        "customer": {
          "auth_key": "uuid-string",
          "name": "John",
          "sname": "Smith"
        }
      }
    ]
  }
  ```

### Get Completed Rides

Retrieves all completed rides within a specified date range.

- **URL**: `/api/completed-rides` or `/api/api/completed-rides`
- **Method**: `GET`
- **Authentication**: None (public endpoint)
- **Parameters**:
  - `start_date` (date, required): Start date in format YYYY-MM-DD
  - `end_date` (date, required): End date in format YYYY-MM-DD (must be equal to or after start_date)

  Note: Parameters can be sent either in the query string (e.g., `/api/completed-rides?start_date=2025-01-01&end_date=2025-01-31`) or in the request body as JSON. Both dates must be valid calendar dates (e.g., February 30th is invalid).

  The endpoint is accessible at both `/api/completed-rides` and `/api/api/completed-rides` to accommodate different URL structures.

- **Response**:
  ```json
  {
    "status": true,
    "message": "Completed rides retrieved successfully",
    "data": [
      {
        "TripID": "uuid-string",
        "Origin_Coordinates": "12.34567890,-45.67891234",
        "End_Coordinates": "23.45678901,-56.78912345",
        "Start_Time": "2023-05-17 15:30:00",
        "End_Time": "2023-05-17 16:15:00",
        "Total_Fare_Amount": 15000,
        "Trip_Distance": 5000,
        "Rating": 4.5,
        "Drivers_Earning": 10500,
        "Driver_LicenseNo": "DL12345678",
        "Vehicle_Registration_No": "T123ABC"
      }
    ]
  }
  ```

## Notifications

The Sepesha API provides real-time notifications to users through Firebase Cloud Messaging (FCM). This section describes the notification system and the types of notifications sent.

### Notification Types

#### Ride Request Notifications

When a new ride is requested, nearby drivers receive a notification with the following information:
- Pickup location
- Customer/Vendor name
- Booking ID and reference
- Notification sound

#### Ride Status Update Notifications

When a ride status changes, relevant parties (customer, vendor, driver) receive notifications:
- **Assigned**: Customer and vendor are notified when a driver is assigned
- **Accepted**: Customer, vendor, and driver are notified when a ride is accepted
- **Started**: Customer and vendor are notified when a driver starts the journey
- **In Transit**: Customer and vendor are notified when the ride is in progress
- **Completed**: Customer, vendor, and driver are notified when the ride is completed

#### Ride Cancellation Notifications

When a ride is cancelled, all parties (customer, vendor, driver) receive a notification with:
- Cancellation reason
- Booking reference
- Previous status

### Setting Up Notifications

To receive notifications, clients must:
1. Register for FCM on their device
2. Send the FCM token to the server using the `/api/user/fcm-token` endpoint
3. Ensure the app is configured to handle both foreground and background notifications

### Notification Payload Structure

All notifications follow this general structure:
```json
{
  "notification": {
    "title": "Notification Title",
    "body": "Notification message text",
    "sound": "default",
    "badge": "1"
  },
  "data": {
    "booking_id": "uuid-string",
    "notification_type": "new_ride_request|status_update|cancellation",
    "status": "pending|assigned|accepted|started|intransit|completed|cancelled",
    "additional_data": "..."
  }
}
```

## Support System

### Create Support Ticket

Creates a new support ticket.

- **URL**: `/api/support-ticket/create`
- **Method**: `POST`
- **Authentication**: JWT (any role)
- **Parameters**:
  - `subject` (string, required): Ticket subject
  - `priority` (string, required): One of "low", "medium", "high"
  - `category` (string, optional): Ticket category
  - `message` (string, required): Initial message
  - `attachment` (file, optional): Attachment (jpg, png, pdf, max 2MB)

- **Response**:
  ```json
  {
    "status": true,
    "message": "Ticket created successfully!",
    "code": 201,
    "data": {
      "id": 1,
      "subject": "Payment Issue",
      "status": "open",
      "sender_id": "uuid-string",
      "priority": "high",
      "category": "Billing"
    }
  }
  ```

### Get Support Tickets

Retrieves all support tickets for the authenticated user.

- **URL**: `/api/support-tickets`
- **Method**: `GET`
- **Authentication**: JWT (any role)
- **Parameters**: None

- **Response**:
  ```json
  {
    "status": true,
    "message": "data found",
    "code": 200,
    "data": [
      {
        "id": 1,
        "subject": "Payment Issue",
        "status": "open",
        "sender_id": "uuid-string",
        "priority": "high",
        "category": "Billing",
        "messages": [
          {
            "id": 1,
            "support_ticket_id": 1,
            "sender_id": "uuid-string",
            "sender_role": "customer",
            "message": "I have an issue with my payment",
            "attachment": "https://example.com/storage/support/123456_abcdef.jpg",
            "is_delivered": true
          }
        ]
      }
    ]
  }
  ```

### Get Support Ticket

Retrieves a specific support ticket by ID.

- **URL**: `/api/support-ticket/{id}`
- **Method**: `GET`
- **Authentication**: JWT (any role)
- **Parameters**: None

- **Response**:
  ```json
  {
    "status": true,
    "message": "data found",
    "code": 200,
    "data": {
      "id": 1,
      "subject": "Payment Issue",
      "status": "open",
      "sender_id": "uuid-string",
      "priority": "high",
      "category": "Billing",
      "messages": [
        {
          "id": 1,
          "support_ticket_id": 1,
          "sender_id": "uuid-string",
          "sender_role": "customer",
          "message": "I have an issue with my payment",
          "attachment": "https://example.com/storage/support/123456_abcdef.jpg",
          "is_delivered": true
        }
      ]
    }
  }
  ```

### Get Support Contacts

Retrieves support contact information.

- **URL**: `/api/support-contacts`
- **Method**: `GET`
- **Authentication**: JWT (any role)
- **Parameters**: None

- **Response**:
  ```json
  {
    "status": true,
    "message": "data found",
    "code": 200,
    "data": [
      {
        "id": 1,
        "name": "Customer Support",
        "email": "support@sepesha.com",
        "phone": "255123456789"
      }
    ]
  }
  ```

## Driver Reviews

### Get Driver Reviews

Retrieves reviews for a specific driver.

- **URL**: `/api/driver-rating/{id}`
- **Method**: `GET`
- **Authentication**: JWT (any role)
- **Parameters**: None

- **Response**:
  ```json
  {
    "status": true,
    "message": "data fetched successfully",
    "code": 200,
    "data": {
      "driver_id": "uuid-string",
      "total_reviews": 10,
      "average_rating": 4.5,
      "reviews": [
        {
          "id": 1,
          "driver_id": "uuid-string",
          "user_id": "uuid-string",
          "rating": 5,
          "review": "Excellent service!",
          "user": {
            "auth_key": "uuid-string",
            "reviewer_id": "uuid-string",
            "reviewer_photo": "https://example.com/storage/documents/123456_abcdef.jpg",
            "reviewer_name": "John Smith"
          }
        }
      ]
    }
  }
  ```

### Create Driver Review

Creates a new review for a driver.

- **URL**: `/api/driver-rating/create`
- **Method**: `POST`
- **Authentication**: JWT (any role)
- **Parameters**:
  - `driver_id` (uuid, required): Driver's auth_key
  - `rating` (integer, required): Rating from 1 to 5
  - `review` (string, optional): Written review

- **Response**:
  ```json
  {
    "status": true,
    "message": "Review created successfully.",
    "data": {
      "id": 1,
      "driver_id": "uuid-string",
      "user_id": "uuid-string",
      "user_type": "customer",
      "rating": 5,
      "review": "Excellent service!"
    }
  }
  ```

## Regions

### Get Regions

Retrieves all available regions.

- **URL**: `/api/regions`
- **Method**: `GET`
- **Authentication**: JWT (any role)
- **Parameters**: None

- **Response**:
  ```json
  {
    "status": true,
    "message": "data found",
    "code": 200,
    "data": [
      {
        "id": 1,
        "name": "Dar es Salaam",
        "country_id": 1
      },
      {
        "id": 2,
        "name": "Arusha",
        "country_id": 1
      }
    ]
  }
  ```

## Fee Categories

### Get Fee Categories

Retrieves all fee categories.

- **URL**: `/api/categories`
- **Method**: `GET`
- **Authentication**: JWT (any role)
- **Parameters**: None

- **Response**:
  ```json
  {
    "status": true,
    "message": "data found",
    "code": 200,
    "data": [
      {
        "id": "uuid-string",
        "name": "Standard Delivery",
        "base_price": 5000,
        "price_per_km": 1000,
        "vehicle_multiplier": 1.0
      }
    ]
  }
  ```

## Role-Specific Endpoints

These endpoints are specific to certain user roles and provide functionality tailored to those roles.

### Driver Operations

- **URL**: `/api/driver/operations`
- **Method**: `GET`
- **Authentication**: JWT (driver role only)
- **Parameters**: None

- **Response**:
  ```json
  {
    "message": "Driver operations endpoint",
    "user_id": "uuid-string",
    "use_type": "driver"
  }
  ```

### Vendor Reports

- **URL**: `/api/vendor/reports`
- **Method**: `GET`
- **Authentication**: JWT (vendor role only)
- **Parameters**: None

- **Response**:
  ```json
  {
    "message": "Vendor reports endpoint",
    "user_id": "uuid-string",
    "user_type": "vendor"
  }
  ```

### Agent Tasks

- **URL**: `/api/agent/tasks`
- **Method**: `GET`
- **Authentication**: JWT (agent role only)
- **Parameters**: None

- **Response**:
  ```json
  {
    "message": "Agent tasks endpoint"
  }
  ```

### Customer Orders

- **URL**: `/api/customer/orders`
- **Method**: `GET`
- **Authentication**: JWT (customer role only)
- **Parameters**: None

- **Response**:
  ```json
  {
    "message": "Customer orders endpoint"
  }
  ```

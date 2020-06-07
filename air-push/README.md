# air-push

Core package of `AirPush` application. Contains shred code and cli-application.

## Usage

```bash
swift run air-push --help
```

Send push notification.

```bash
swift run air-push \
    --device-token 69277D3DD254215B427D330A43E5E6E2A197E1758468AE6F93EC993850C0A3F6 \
    --certificate-name "com.example.app" \
    --body '{ "aps": { "alert": { "title": "Hello" } } }'
```

Send push notification from file *push.json*.

```bash
swift run air-push \
    --device-token 69277D3DD254215B427D330A43E5E6E2A197E1758468AE6F93EC993850C0A3F6 \
    --certificate-name "com.example.app" \
    --file push.json
```

## Apple documentation

- [Sending Notification Requests to APNs](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/sending_notification_requests_to_apns)
- [Communicating with APNs](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CommunicatingwithAPNs.html#//apple_ref/doc/uid/TP40008194-CH11-SW1)
- [Xcode 11.4 Release Notes](https://developer.apple.com/documentation/xcode_release_notes/xcode_11_4_release_notes)

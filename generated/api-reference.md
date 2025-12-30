# VIVEN SDK API Reference

> 자동 생성: 2025-12-30 16:23:59

## Deprecated APIs

| API | 메시지 |
|-----|--------|
| `PlayEmote(AnimationClip, bool)` | SDKCustomAnimationModule를 사용해주세요 |

## ChatAPI

### Classes
- `TextChat`: 텍스트 채팅 API

### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `SendChannelTextMessage(string)` | message | `void` | 채팅 보내기 API |
| `SendDirectTextMessage(string, string)` | message, vivenReceiverUserId | `void` | 귓속말 보내기 API |
| `LockTextChatUiOpen()` | - | `void` | 채팅창 UI 열기 잠금 |
| `UnlockTextChatUiOpen()` | - | `void` | 채팅창 UI 열기 잠금 해제 |
| `OnChannelTextMessageReceived(string, string)` | sender, message | `void` | 메시지 수신 이벤트 |
| `OnDirectTextMessageReceived(string, string)` | sender, message | `void` | 귓속말 수신 이벤트 |

## HandTrackingAPI

### Classes
- `HandTracking`: N/A

### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `CommandVibrationHaptic(float, float, SDKHandedness, SDKFingerType, bool)` | intensity, duration, handType, finger, isHandVibration | `void` | N/A |
| `StopVibrationHaptic(SDKHandedness)` | handType | `void` | N/A |
| `CommandForceHaptic(float, float, bool, SDKHandedness, SDKFingerType)` | intensity, bendValue, inward, handType, fingerType | `void` | N/A |
| `StopForceHaptic(SDKHandedness)` | handType | `void` | N/A |
| `CommandFeverHaptic(float, float, SDKHandedness)` | temp, duration, handType | `void` | N/A |
| `StopFeverHaptic(SDKHandedness)` | handType | `void` | N/A |

## PlayerAPI

### Classes
- `Player.Mine`: 자신의 플레이어 정보를 가져오는 API
- `Player.Other`: 다른 사람의 플레이어 정보를 가져오는 API
- `Player`: 플레이어 관련 API

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `Nickname` | `System.String` | 유저의 닉네임 입니다. |
| `UserID` | `System.String` | 유저의 ID 입니다. |
| `PlayMode` | `System.String` | 현재 PC, XR 등 PlayMode를 가져옵니다. |
| `CharacterController` | `Global.CharacterController` | 나의 캐릭터 컨트롤러 |
| `CharacterAnimator` | `Global.Animator` | 나의 캐릭터 Animator |
| `CharacterAnimatorController` | `Global.RuntimeAnimatorController` | 나의 캐릭터 Runtime Animator Controller |
| `CharacterHead` | `Global.Transform` | 캐릭터의 머리 Transform |
| `CharacterRightHand` | `Global.Transform` | 캐릭터의 오른손 Transform |
| `CharacterLeftHand` | `Global.Transform` | 캐릭터의 왼손 Transform |
| `CharacterMoveLock` | `System.Boolean` | 캐릭터 움직임 제한 여부 |

### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `GetPlayerData()` | - | `Global.LuaTable` | 나의 PlayerData를 가져옵니다.
<pre><code class=" |
| `GetPlayerProfileImage(LuaFunction)` | callback | `void` | 나의 Profile Image를 가져옵니다. |
| `MultiplyPlayerSpeed(float)` | modifier | `void` | 플레이어의 이동속도를 증가시킵니다. |
| `ResetPlayerSpeed()` | - | `void` | 플레이어의 이동속도를 초기화합니다. |
| `SetCameraLock(VivenCameraLockMode)` | lockMode | `void` | N/A |
| `TeleportPlayer(Vector3, Quaternion)` | pos, rot | `void` | 캐릭터를 순간이동 합니다. |
| `AddMoveInput(Vector2)` | move | `void` | 캐릭터의 이동 입력을 추가합니다. |
| `AddViewInput(Vector2)` | view | `void` | 캐릭터의 View 입력을 추가합니다. |
| `PlayEmote(AnimationClip, bool)` | animationClip, firstPosition | `void` | 캐릭터의 Emote를 재생합니다. |
| `StopEmote(AnimationClip)` | animationClip | `void` | Emote를 중지합니다. |
| `ChangeAvatar(string)` | avatarId | `void` | 아바타를 변경합니다. |
| `Sit(VivenSittable)` | sittable | `void` | Sittable에 앉기를 시도합니다. |
| `TryGrab(VivenGrabbableModule, bool, bool, GrabInterpolation)` | gb, isLeft, isForce, interpolation | `System.Threading.Tasks.Task{System.Boolean}` | 내 플레이어가 GrabbableModule을 잡도록 시도합니다. 이미 잡 |
| `EndAllInteractions()` | - | `void` | 진행중인 모든 상호작용을 종료합니다.
상호작용에는 Grab, Place  |
| `GetPlayerID(string)` | nickName | `System.String` | Player의 닉네임으로 PlayerID를 가져옵니다.
내 아이디는 <x |
| `GetPlayerData(string)` | playerID | `Global.LuaTable` | Player의 PlayerID로 PlayerData를 가져옵니다.
<pr |
| `GetPlayerProfileImage(string, LuaFunction)` | playerId, callback | `void` | Player의 PlayerID로 Profile Image를 가져옵니다. |
| `TeleportOtherPlayer(string, Vector3, Quaternion)` | playerId, pos, rot | `void` | 다른 플레이어를 순간이동시킵니다. |
| `GetOtherPlayerRig(string)` | playerId | `Global.Transform` | 다른 플레이어의 플레이어 Rig Transform을 가져옵니다. |
| `GetOtherPlayerHead(string)` | playerId | `Global.Transform` | 다른 플레이어의 캐릭터 Head Transform을 가져옵니다. |

## RecordingAPI

### Classes
- `ScreenRecording`: 화면 녹화 API

### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `GetFrameRate()` | - | `System.Single` | 녹화 FrameRate를 가져옵니다. |
| `SetFrameRate(int)` | frameRate | `void` | 녹화 FrameRate를 설정합니다. |
| `GetOutputPath()` | - | `System.String` | 녹화 영상 저장 경로를 가져옵니다. |
| `SetOutputPath(string)` | path | `void` | 녹화 영상 저장 경로를 설정합니다. |
| `GetOutputFileName()` | - | `System.String` | 녹화 영상 파일명을 가져옵니다. |
| `SetOutputFileName(string)` | fileName | `void` | 녹화 영상의 파일명을 설정합니다. |
| `ClearOutputPaths()` | - | `void` | 녹화 경로 및 파일명을 초기화합니다. 초기값은 OS의 동영상 폴더 경로입 |
| `GetCurrentAudioInputDevice()` | - | `System.String` | 현재 영상의 녹음 장치명을 가져옵니다. |
| `SetAudioInputDevice(string)` | deviceName | `void` | 영상의 녹음 장치를 설정합니다. loopback 장치를 사용해야 합니다. |
| `StartRecording()` | - | `void` | 녹화를 시작합니다. |
| `StopRecording()` | - | `void` | 녹화를 중단합니다. |
| `PauseRecording()` | - | `void` | 녹화를 일시정지합니다. |
| `ResumeRecording()` | - | `void` | 녹화를 재개합니다. |

## RoomAPI

### Classes
- `Room.Map.Setting`: 맵 Setting 관련 API
- `Room.Map`: VMap 관련 API 입니다.
- `Room.Player`: 방 관련 Player API입니다.
- `Room.VoiceChat`: 음성 채팅 API입니다.
- `Room`: Room 관련 API

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `SkyDomeTime` | `System.Single` | SkyDome의 시간을 설정합니다. [0, 24] 사이의 값이어야 합니다. |
| `CurrentRoomPlayers` | `System.Collections.Generic.Dictionary{System.String,UserData}` | 현재 Room에 있는 플레이어들의 UserData를 가져옵니다. |

### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `SetActiveSkyDome(bool)` | active | `void` | SkyDome을 활성화/비활성화 합니다. |
| `SetSkyDomeFog(float)` | fog | `void` | SkyDome의 Fog를 설정합니다. |
| `GetMapProp(string)` | propId | `System.String` | Map의 Property를 가져옵니다. key가 없다면 null을 반환합 |
| `SetMapProp(string, string)` | propId, propVal | `void` | Map의 Property를 설정합니다. key가 없다면 새로 생성합니다. |
| `KickPlayer(string)` | playerId | `void` | 플레이어를 강제 퇴장 시킵니다. |
| `MicMute(bool)` | isMute | `void` | 음성 채팅 마이크를 음소거합니다. (내 음성이 입력되지 않습니다.) |
| `SpeakerMute(bool)` | isMute | `void` | 음성 채팅 스피커를 음소거합니다. (상대방의 음성이 출력되지 않습니다.) |
| `SetSpeakerVolume(float)` | volume | `void` | 음성 채팅의 출력 볼륨을 설정합니다. |
| `SetMicVolume(float)` | volume | `void` | 내 마이크 볼륨을 설정합니다. |
| `SetPlayerVolume(string, float)` | userId, volume | `void` | 특정 유저의 마이크 볼륨을 설정합니다. |
| `MutePlayer(string, bool)` | userID, isMute | `void` | 특정 유저의 마이크를 음소거합니다. |
| `GetVoiceData()` | - | `Global.LuaTable` | 나의 음성 데이터를 가져옵니다.
<pre><code class="lang |
| `GetVoiceData(string)` | userId | `Global.LuaTable` | 상대방의 음성 데이터를 가져옵니다.
<pre><code class="la |
| `GetCreatorUserID()` | - | `System.String` | Room 생성자의 UserID를 가져옵니다. |
| `GetRoomProp(string)` | propId | `System.String` | Room의 Property를 가져옵니다.
프로퍼티 ID가 없다면 null |
| `SetRoomProp(string, string)` | propId, propVal | `void` | Room의 Property를 설정합니다. 프로퍼티 ID가 없다면 새로 생 |
| `RegisterRoomPropChanged(string, LuaFunction)` | propId, callBack | `void` | 해당 프로퍼티 ID의 값이 변경되었을 때 호출될 콜백을 등록합니다.
<b |
| `UnRegisterRoomPropChanged(string, LuaFunction)` | propId, callBack | `void` | <xref href="TwentyOz.VivenSDK.Scripts.Co |
| `LeaveRoom()` | - | `void` | 현재 방을 나가고 마이룸으로 이동합니다. |

## SystemAPI

### Classes
- `Locale`: 언어 설정 API
- `VivenSystem.Mouse`: N/A
- `VivenSystem`: N/A

### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `GetLocale()` | - | `System.String` | Viven의 현재 언어 설정을 가져옵니다. |
| `SetLocale(string)` | locale | `System.String` | Viven의 언어 설정을 변경합니다. |
| `ShowCursor()` | - | `void` | 마우스를 보여줍니다. |
| `HideCursor()` | - | `void` | 마우스를 감춥니다. |

## UIAPI

### Classes
- `UI`: UI API

## VivenUtilAPI

### Classes
- `VivenUtil.Physics`: Viven에서 제공하는 Physics 관련 Utility
- `VivenUtil`: Viven에서 제공하는 Utility API

### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `RayCast(Ray, float, out RaycastHit)` | ray, distance, hitInfo | `System.Boolean` | Raycast를 실행합니다. |
| `RayCastAll(Ray, float)` | ray, distance | `Global.RaycastHit[]` | RaycastAll을 실행합니다. |

## Web

### Classes
- `Web`: Viven Web API

### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `GetAvatarProfile(Action<Texture2D>)` | onFinished | `void` | 현재 로그인한 유저의 아바타 프로필을 가져옵니다. |

## WebRequest

### Classes
- `WebRequest`: N/A

### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `Post(string, string, string)` | uri, postData, contentType | `Global.UnityWebRequest` | N/A |

## XRAPI

### Classes
- `XR`: XR 관련 API

### Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `StartControllerVibration(bool, float, float)` | isLeft, amplitude, duration | `void` | controller 진동을 시작합니다. |
| `StopControllerVibration(bool)` | isLeft | `void` | controller 진동을 멈춥니다. |

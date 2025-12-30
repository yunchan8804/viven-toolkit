---@meta
-- VIVEN SDK Lua Type Stubs
-- 자동 생성: 2025-12-30

---@class Chat
Chat = {}

---@param message string
function Chat.SendChannelTextMessage(string)(message) end

---@param message string
---@param vivenReceiverUserId string
function Chat.SendDirectTextMessage(string, string)(message, vivenReceiverUserId) end

function Chat.LockTextChatUiOpen()() end

function Chat.UnlockTextChatUiOpen()() end

---@param sender string
---@param message string
function Chat.OnChannelTextMessageReceived(string, string)(sender, message) end

---@param sender string
---@param message string
function Chat.OnDirectTextMessageReceived(string, string)(sender, message) end

---@class HandTracking
HandTracking = {}

---@param intensity number
---@param duration number
---@param handType any
---@param finger any
---@param isHandVibration boolean
function HandTracking.CommandVibrationHaptic(float, float, SDKHandedness, SDKFingerType, bool)(intensity, duration, handType, finger, isHandVibration) end

---@param handType any
function HandTracking.StopVibrationHaptic(SDKHandedness)(handType) end

---@param intensity number
---@param bendValue number
---@param inward boolean
---@param handType any
---@param fingerType any
function HandTracking.CommandForceHaptic(float, float, bool, SDKHandedness, SDKFingerType)(intensity, bendValue, inward, handType, fingerType) end

---@param handType any
function HandTracking.StopForceHaptic(SDKHandedness)(handType) end

---@param temp number
---@param duration number
---@param handType any
function HandTracking.CommandFeverHaptic(float, float, SDKHandedness)(temp, duration, handType) end

---@param handType any
function HandTracking.StopFeverHaptic(SDKHandedness)(handType) end

---@class Player
---@field Nickname string
---@field UserID string
---@field PlayMode string
---@field CharacterController any
---@field CharacterAnimator any
---@field CharacterAnimatorController any
---@field CharacterHead any
---@field CharacterRightHand any
---@field CharacterLeftHand any
---@field CharacterMoveLock boolean
Player = {}

---@return any
function Player.GetPlayerData()() end

---@param callback any
function Player.GetPlayerProfileImage(LuaFunction)(callback) end

---@param modifier number
function Player.MultiplyPlayerSpeed(float)(modifier) end

function Player.ResetPlayerSpeed()() end

---@param lockMode any
function Player.SetCameraLock(VivenCameraLockMode)(lockMode) end

---@param pos any
---@param rot any
function Player.TeleportPlayer(Vector3, Quaternion)(pos, rot) end

---@param move any
function Player.AddMoveInput(Vector2)(move) end

---@param view any
function Player.AddViewInput(Vector2)(view) end

---@param animationClip any
---@param firstPosition boolean
function Player.PlayEmote(AnimationClip, bool)(animationClip, firstPosition) end

---@param animationClip any
function Player.StopEmote(AnimationClip)(animationClip) end

---@param avatarId string
function Player.ChangeAvatar(string)(avatarId) end

---@param sittable any
function Player.Sit(VivenSittable)(sittable) end

---@param gb any
---@param isLeft boolean
---@param isForce boolean
---@param interpolation any
---@return any
function Player.TryGrab(VivenGrabbableModule, bool, bool, GrabInterpolation)(gb, isLeft, isForce, interpolation) end

function Player.EndAllInteractions()() end

---@param nickName string
---@return string
function Player.GetPlayerID(string)(nickName) end

---@param playerID string
---@return any
function Player.GetPlayerData(string)(playerID) end

---@param playerId string
---@param callback any
function Player.GetPlayerProfileImage(string, LuaFunction)(playerId, callback) end

---@param playerId string
---@param pos any
---@param rot any
function Player.TeleportOtherPlayer(string, Vector3, Quaternion)(playerId, pos, rot) end

---@param playerId string
---@return any
function Player.GetOtherPlayerRig(string)(playerId) end

---@param playerId string
---@return any
function Player.GetOtherPlayerHead(string)(playerId) end

---@class Recording
Recording = {}

---@return number
function Recording.GetFrameRate()() end

---@param frameRate integer
function Recording.SetFrameRate(int)(frameRate) end

---@return string
function Recording.GetOutputPath()() end

---@param path string
function Recording.SetOutputPath(string)(path) end

---@return string
function Recording.GetOutputFileName()() end

---@param fileName string
function Recording.SetOutputFileName(string)(fileName) end

function Recording.ClearOutputPaths()() end

---@return string
function Recording.GetCurrentAudioInputDevice()() end

---@param deviceName string
function Recording.SetAudioInputDevice(string)(deviceName) end

function Recording.StartRecording()() end

function Recording.StopRecording()() end

function Recording.PauseRecording()() end

function Recording.ResumeRecording()() end

---@class Room
---@field SkyDomeTime number
---@field CurrentRoomPlayers any
Room = {}

---@param active boolean
function Room.SetActiveSkyDome(bool)(active) end

---@param fog number
function Room.SetSkyDomeFog(float)(fog) end

---@param propId string
---@return string
function Room.GetMapProp(string)(propId) end

---@param propId string
---@param propVal string
function Room.SetMapProp(string, string)(propId, propVal) end

---@param playerId string
function Room.KickPlayer(string)(playerId) end

---@param isMute boolean
function Room.MicMute(bool)(isMute) end

---@param isMute boolean
function Room.SpeakerMute(bool)(isMute) end

---@param volume number
function Room.SetSpeakerVolume(float)(volume) end

---@param volume number
function Room.SetMicVolume(float)(volume) end

---@param userId string
---@param volume number
function Room.SetPlayerVolume(string, float)(userId, volume) end

---@param userID string
---@param isMute boolean
function Room.MutePlayer(string, bool)(userID, isMute) end

---@return any
function Room.GetVoiceData()() end

---@param userId string
---@return any
function Room.GetVoiceData(string)(userId) end

---@return string
function Room.GetCreatorUserID()() end

---@param propId string
---@return string
function Room.GetRoomProp(string)(propId) end

---@param propId string
---@param propVal string
function Room.SetRoomProp(string, string)(propId, propVal) end

---@param propId string
---@param callBack any
function Room.RegisterRoomPropChanged(string, LuaFunction)(propId, callBack) end

---@param propId string
---@param callBack any
function Room.UnRegisterRoomPropChanged(string, LuaFunction)(propId, callBack) end

function Room.LeaveRoom()() end

---@class System
System = {}

---@return string
function System.GetLocale()() end

---@param locale string
---@return string
function System.SetLocale(string)(locale) end

function System.ShowCursor()() end

function System.HideCursor()() end

---@class VivenUtil
VivenUtil = {}

---@param ray any
---@param distance number
---@param hitInfo any
---@return boolean
function VivenUtil.RayCast(Ray, float, out RaycastHit)(ray, distance, hitInfo) end

---@param ray any
---@param distance number
---@return any
function VivenUtil.RayCastAll(Ray, float)(ray, distance) end

---@class Web
Web = {}

---@param onFinished any
function Web.GetAvatarProfile(Action<Texture2D>)(onFinished) end

---@class WebRequest
WebRequest = {}

---@param uri string
---@param postData string
---@param contentType string
---@return any
function WebRequest.Post(string, string, string)(uri, postData, contentType) end

---@class XR
XR = {}

---@param isLeft boolean
---@param amplitude number
---@param duration number
function XR.StartControllerVibration(bool, float, float)(isLeft, amplitude, duration) end

---@param isLeft boolean
function XR.StopControllerVibration(bool)(isLeft) end

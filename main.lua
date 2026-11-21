require "import"
import "android.speech.SpeechRecognizer"
import "android.speech.RecognizerIntent"
import "android.speech.RecognitionListener"
import "android.content.Intent"
import "android.net.Uri"
import "android.widget.LinearLayout"
import "android.widget.ListView"
import "android.widget.ArrayAdapter"
import "android.widget.Switch"
import "android.widget.Button"
import "android.widget.EditText"
import "android.widget.TextView"
import "android.widget.ScrollView"
import "android.content.Context"
import "android.os.Vibrator"
import "android.os.Handler"
import "android.os.Looper"
import "android.os.PowerManager"
import "android.os.StrictMode"
import "android.view.View"
import "android.media.AudioManager"
import "android.media.ToneGenerator"
import "android.media.MediaRecorder"
import "android.util.Base64"
import "com.androlua.LuaDialog"
import "com.androlua.Http"
import "cjson"
import "java.lang.Runnable"
import "java.lang.String"
import "java.lang.Byte"
import "java.util.Locale"
import "java.util.HashMap"
import "java.lang.reflect.Array"
import "java.net.URL"
import "java.io.File"
import "java.io.FileInputStream"
import "java.io.FileOutputStream"
import "java.io.ByteArrayOutputStream"
import "java.io.BufferedReader"
import "java.io.InputStreamReader"
import "java.security.SecureRandom"
import "java.security.MessageDigest"
import "javax.crypto.Cipher"
import "javax.crypto.Mac"
import "javax.crypto.SecretKeyFactory"
import "javax.crypto.spec.PBEKeySpec"
import "javax.crypto.spec.SecretKeySpec"
import "javax.crypto.spec.IvParameterSpec"
local context = service
local prefs = service.getSharedPreferences("INPUT_SUARA_AI_ULTRA", Context.MODE_PRIVATE)
local vibrator = context.getSystemService(Context.VIBRATOR_SERVICE)
local pm = context.getSystemService(Context.POWER_SERVICE)
local audioManager = context.getSystemService(Context.AUDIO_SERVICE)
local mainHandler = Handler(Looper.getMainLooper())
pcall(function()
local policy = StrictMode.ThreadPolicy.Builder().permitAll().build()
StrictMode.setThreadPolicy(policy)
end)
local wakeLock = nil
local CURRENT_VERSION = "1.0"
local GITHUB_OWNER = "abilmaulid266-creator"
local GITHUB_REPO = "input-suara-ai-ultra"
local GITHUB_BRANCH = "main"
local UPDATE_SCRIPT_URL = "https://raw.githubusercontent.com/" .. GITHUB_OWNER .. "/" .. GITHUB_REPO .. "/" .. GITHUB_BRANCH .. "/main.lua"
local UPDATE_VERSION_URL = "https://raw.githubusercontent.com/" .. GITHUB_OWNER .. "/" .. GITHUB_REPO .. "/" .. GITHUB_BRANCH .. "/version.txt"
local UPDATE_MESSAGE_URL = "https://raw.githubusercontent.com/" .. GITHUB_OWNER .. "/" .. GITHUB_REPO .. "/" .. GITHUB_BRANCH .. "/pesan%20pembaruan.txt"
local API_SCRIPT_URL = "https://api.github.com/repos/" .. GITHUB_OWNER .. "/" .. GITHUB_REPO .. "/contents/main.lua?ref=" .. GITHUB_BRANCH
local API_VERSION_URL = "https://api.github.com/repos/" .. GITHUB_OWNER .. "/" .. GITHUB_REPO .. "/contents/version.txt?ref=" .. GITHUB_BRANCH
local API_MESSAGE_URL = "https://api.github.com/repos/" .. GITHUB_OWNER .. "/" .. GITHUB_REPO .. "/contents/pesan%20pembaruan.txt?ref=" .. GITHUB_BRANCH
local BACKUP_FILE_PATHS = {
"/storage/emulated/0/Input_Suara_AI_Ultra_Backup.enc",
"/storage/emulated/0/Download/Input_Suara_AI_Ultra_Backup.enc"
}
local YOUTUBE_URL = "https://youtube.com/@abilmaulid202?si=-fEtUU3EX7BHWN3y"
local TELEGRAM_URL = "https://t.me/+QbJrZVQ9BshiMjVl"
_G.ULTRA_REC_STATE = _G.ULTRA_REC_STATE or {
isRecording = false,
recorder = nil,
audioPath = nil,
targetNode = nil
}
_G.ACTIVE_MAIN_DIALOG = nil
_G.IS_UPDATE_DIALOG_OPEN = false
local AI_BASE_URL = "https://ai-hub.schoolofmindlight.workers.dev/"
local GEMINI_API_BASE = "https://generativelanguage.googleapis.com/v1beta/models"
local AI_MODELS = {
"gpt-sol",
"gpt-mini",
"gpt-luna",
"gpt-terra",
"gpt-instant",
"gpt-5.5",
"o3",
"deepseek",
"deepseek-pro",
"gemini-flash",
"gemini-pro",
"claude-sonnet",
"claude-opus",
"qwen",
"llama",
"perplexity",
"grok",
"kimi"
}
local DEFAULT_GEMINI_MODELS = {
"Gemini Flash",
"Gemini Flash Latest",
"Gemini 3.5 Transcribe",
"Gemini 3.6 Flash",
"Gemini 3.7",
"Gemini 3.7 Flash"
}
local GEMINI_MODEL_ALIAS = {
["Gemini Flash"] = "gemini-2.5-flash",
["Gemini Flash Latest"] = "gemini-flash-latest",
["Gemini 3.5 Transcribe"] = "gemini-3.5-transcribe",
["Gemini 3.6 Flash"] = "gemini-3.6-flash",
["Gemini 3.7"] = "gemini-3.7",
["Gemini 3.7 Flash"] = "gemini-3.7-flash"
}
local AI_STYLES = {
"Normal",
"Profesional",
"Lucu",
"Romantis",
"Kasual",
"Formal",
"Singkat",
"Puitis",
"Tegas",
"Ramah",
"Akademis",
"Persuasif",
"Storytelling",
"Sarkastik",
"Empatik",
"Jurnalistik",
"Motivasi",
"Diplomatis",
"Bisnis",
"Edukatif",
"Kreatif",
"Poin-poin",
"Dramatis",
"Sopan Santun",
"Netral"
}
local EMOJI_LEVELS = {
"Rendah",
"Sedang",
"Tinggi"
}
local CASE_MODES = {
"Normal",
"Kapitalisasi Otomatis",
"Huruf Besar Semua",
"Huruf Kecil Semua"
}
local FAKE_LINK_DOMAINS = {
".com",
".org",
".net",
".id",
".co.id",
".info",
".biz",
".xyz"
}
local FAKE_EMAIL_DOMAINS = {
"@gmail.com",
"@yahoo.com",
"@outlook.com",
"@hotmail.com",
"@icloud.com",
"@proton.me",
"@mail.com",
"@yandex.com",
"@live.com",
"@zoho.com"
}
local DEFAULT_AI_INSTRUCTION = "Revisi tulisan saya dengan penataan simbol yang benar tanpa mengubah makna dan tanpa menambahkan apapun. Langsung kirim hasil perbaikan saja tanpa penjelasan tanpa komentar sedikitpun"
local function safeSpeak(text)
if text and #tostring(text) > 0 then
pcall(function() service.speak(tostring(text)) end)
end
end
local function trimText(s)
if not s then return "" end
local str = tostring(s):gsub("^\239\187\191", "")
return str:gsub("^%s+", ""):gsub("%s+$", "")
end
local function withCacheBuster(url)
local sep = url:find("?", 1, true) and "&" or "?"
return url .. sep .. "t=" .. tostring(os.time()) .. tostring(math.random(100, 999))
end
local function urlencode(s)
return tostring(s):gsub("([^%w %-%_%.%~])", function(c)
return string.format("%%%02X", string.byte(c))
end):gsub(" ", "+")
end
local function escapePattern(text)
return tostring(text):gsub("([^%w])", "%%%1")
end
local function buildCaseInsensitivePattern(literal)
local str = tostring(literal)
local out = {}
for i = 1, #str do
local ch = str:sub(i, i)
if ch:match("%a") then
table.insert(out, "[" .. ch:lower() .. ch:upper() .. "]")
else
table.insert(out, escapePattern(ch))
end
end
local core = table.concat(out, "")
local startsWord = str:sub(1, 1):match("[%w_]") ~= nil
local endsWord = str:sub(-1, -1):match("[%w_]") ~= nil
if startsWord then core = "%f[%w_]" .. core end
if endsWord then core = core .. "%f[^%w_]" end
return core
end
local function getPref(key, defVal)
local t = type(defVal)
if t == "boolean" then return prefs.getBoolean(key, defVal)
elseif t == "number" then return prefs.getInt(key, defVal)
else return prefs.getString(key, defVal) end
end
local function setPref(key, value)
local editor = prefs.edit()
local t = type(value)
if t == "boolean" then editor.putBoolean(key, value)
elseif t == "number" then editor.putInt(key, value)
else editor.putString(key, value) end
editor.apply()
end
local function loadJSON(key)
local ok, data = pcall(cjson.decode, getPref(key, "{}"))
return (ok and type(data) == "table") and data or {}
end
local function saveJSON(key, data)
pcall(function() setPref(key, cjson.encode(data)) end)
end
local function closeExtensionCompletely()
_G.IS_UPDATE_DIALOG_OPEN = false
if _G.ACTIVE_MAIN_DIALOG then
pcall(function() _G.ACTIVE_MAIN_DIALOG.dismiss() end)
_G.ACTIVE_MAIN_DIALOG = nil
end
end
local function openExternalLink(url)
pcall(function()
local intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
service.startActivity(intent)
end)
closeExtensionCompletely()
end
local function writeTextToFile(path, content)
pcall(function()
local parent = File(path).getParentFile()
if parent and not parent.exists() then
parent.mkdirs()
end
end)
local okLua = false
pcall(function()
local f = io.open(path, "wb")
if f then
f:write(content)
f:close()
okLua = true
end
end)
if okLua then return true end
local okJava = false
pcall(function()
local fos = FileOutputStream(path, false)
fos.write(String(content).getBytes("UTF-8"))
fos.flush()
fos.close()
okJava = true
end)
return okJava
end
local function readTextFromFile(path)
local content = nil
pcall(function()
local f = io.open(path, "rb")
if f then
content = f:read("*a")
f:close()
end
end)
if content and #content > 0 then
return content
end
pcall(function()
local fileObj = File(path)
if fileObj.exists() and fileObj.isFile() then
local fis = FileInputStream(fileObj)
local reader = BufferedReader(InputStreamReader(fis, "UTF-8"))
local sb = {}
local line = reader.readLine()
while line ~= nil do
table.insert(sb, tostring(line))
line = reader.readLine()
end
reader.close()
fis.close()
content = table.concat(sb, "\n")
end
end)
return content
end
local function resolveCurrentScriptPaths()
local paths = {}
local seen = {}
local function addPath(p)
if p and #tostring(p) > 0 then
local clean = tostring(p)
if not seen[clean] then
seen[clean] = true
table.insert(paths, clean)
end
end
end
local info = debug.getinfo(1, "S")
if info and info.source and info.source:sub(1, 1) == "@" then
addPath(info.source:sub(2))
end
if service then
pcall(function()
if service.getLuaPath then addPath(service.getLuaPath()) end
end)
pcall(function()
if service.getLuaDir then addPath(tostring(service.getLuaDir()) .. "/main.lua") end
end)
end
local pluginRoots = {
"/storage/emulated/0/解说/Plugin",
"/storage/emulated/0/Jieshuo/Plugin",
"/sdcard/解说/Plugin",
"/sdcard/Jieshuo/Plugin"
}
for _, root in ipairs(pluginRoots) do
pcall(function()
local dir = File(root)
if dir.exists() and dir.isDirectory() then
local subDirs = dir.listFiles()
if subDirs then
local count = Array.getLength(subDirs)
for i = 0, count - 1 do
local sub = Array.get(subDirs, i)
if sub and sub.isDirectory() then
local files = sub.listFiles()
if files then
local fCount = Array.getLength(files)
for j = 0, fCount - 1 do
local f = Array.get(files, j)
if f and f.isFile() and tostring(f.getName()):lower():sub(-4) == ".lua" then
local fPath = tostring(f.getAbsolutePath())
local body = readTextFromFile(fPath)
if body and body:find("INPUT_SUARA_AI_ULTRA", 1, true) then
addPath(fPath)
end
end
end
end
end
end
end
end
end)
end
addPath("/storage/emulated/0/解说/Plugin/Input Suara AI Ultra/main.lua")
addPath("/storage/emulated/0/Jieshuo/Plugin/Input Suara AI Ultra/main.lua")
return paths
end
local function unwrapGithubApiPayload(rawBody)
local text = tostring(rawBody or "")
local trimmed = trimText(text)
if trimmed:sub(1, 1) == "{" and trimmed:find('"content"') and trimmed:find('"base64"') then
local ok, j = pcall(cjson.decode, trimmed)
if ok and type(j) == "table" and j.content and j.encoding == "base64" then
local cleanB64 = tostring(j.content):gsub("%s+", "")
local okDec, decodedBytes = pcall(function()
return Base64.decode(cleanB64, Base64.DEFAULT)
end)
if okDec and decodedBytes then
return tostring(String(decodedBytes, "UTF-8"))
end
end
end
return text
end
local function fetchWithJavaHttp(targetUrl, isGithubApi, ghToken)
local status = 0
local content = ""
pcall(function()
local urlObj = URL(targetUrl)
local conn = urlObj.openConnection()
conn.setRequestMethod("GET")
conn.setConnectTimeout(9000)
conn.setReadTimeout(11000)
conn.setInstanceFollowRedirects(true)
conn.setUseCaches(false)
conn.setRequestProperty("User-Agent", "InputSuaraAIUltra-Android")
if #ghToken > 0 then
conn.setRequestProperty("Authorization", "Bearer " .. ghToken)
end
if isGithubApi then
conn.setRequestProperty("Accept", "application/vnd.github.v3.raw")
else
conn.setRequestProperty("Accept", "text/plain, */*")
end
conn.connect()
status = tonumber(tostring(conn.getResponseCode())) or 0
if status == 200 then
local is = conn.getInputStream()
local reader = BufferedReader(InputStreamReader(is, "UTF-8"))
local lines = {}
local line = reader.readLine()
while line ~= nil do
table.insert(lines, tostring(line))
line = reader.readLine()
end
reader.close()
is.close()
content = table.concat(lines, "\n")
end
conn.disconnect()
end)
if status == 200 and #content > 0 then
content = unwrapGithubApiPayload(content)
end
return status, content
end
local function dispatchAsyncGet(targetUrl, isGithubApi, ghToken, onDone)
local needsHeaders = isGithubApi or (#ghToken > 0)
if needsHeaders then
local headers = HashMap()
headers.put("User-Agent", "InputSuaraAIUltra-Android")
if #ghToken > 0 then
headers.put("Authorization", "Bearer " .. ghToken)
end
if isGithubApi then
headers.put("Accept", "application/vnd.github.v3.raw")
else
headers.put("Accept", "text/plain, */*")
end
local okH = pcall(function()
Http.get(targetUrl, headers, function(code, body)
local sc = tonumber(tostring(code)) or 0
local txt = body and tostring(body) or ""
if sc == 200 and #txt > 0 then
onDone(200, txt)
else
local jSc, jBody = fetchWithJavaHttp(targetUrl, isGithubApi, ghToken)
onDone(jSc ~= 0 and jSc or sc, #jBody > 0 and jBody or txt)
end
end)
end)
if not okH then
local jSc, jBody = fetchWithJavaHttp(targetUrl, isGithubApi, ghToken)
onDone(jSc, jBody)
end
return
end
local okStd = pcall(function()
Http.get(targetUrl, function(code, body)
onDone(tonumber(tostring(code)) or 0, body and tostring(body) or "")
end)
end)
if not okStd then
local jSc, jBody = fetchWithJavaHttp(targetUrl, isGithubApi, ghToken)
onDone(jSc, jBody)
end
end
local function fetchGithubResource(rawUrl, apiUrl, cdnUrls, callback)
local ghToken = trimText(getPref("github_private_token", ""))
local settled = false
local completedCount = 0
local lastStatus = 0
local endpoints = {}
if #ghToken > 0 then
table.insert(endpoints, { url = apiUrl, isApi = true })
table.insert(endpoints, { url = withCacheBuster(rawUrl), isApi = false })
else
table.insert(endpoints, { url = withCacheBuster(rawUrl), isApi = false })
table.insert(endpoints, { url = rawUrl, isApi = false })
for _, cUrl in ipairs(cdnUrls) do
table.insert(endpoints, { url = cUrl, isApi = false })
end
table.insert(endpoints, { url = apiUrl, isApi = true })
end
local totalEndpoints = #endpoints
mainHandler.postDelayed(Runnable({
run = function()
if not settled then
settled = true
callback(lastStatus, "")
end
end
}), 10000)
for idx, ep in ipairs(endpoints) do
local delayMs = (idx - 1) * 550
mainHandler.postDelayed(Runnable({
run = function()
if settled then return end
dispatchAsyncGet(ep.url, ep.isApi, ghToken, function(sc, rawBody)
if settled then return end
completedCount = completedCount + 1
local textBody = (#rawBody > 0) and unwrapGithubApiPayload(rawBody) or ""
if sc == 200 and #textBody > 0 then
settled = true
callback(200, textBody)
return
end
if sc ~= 0 then
lastStatus = sc
end
if completedCount >= totalEndpoints then
settled = true
callback(lastStatus, "")
end
end)
end
}), delayMs)
end
end
local function httpPostJson(targetUrl, jsonPayload, callback)
local headers = HashMap()
headers.put("Content-Type", "application/json; charset=UTF-8")
headers.put("Accept", "application/json, text/plain, */*")
local ok4 = pcall(function()
Http.post(targetUrl, jsonPayload, headers, function(code, body)
callback(tonumber(tostring(code)) or 0, body and tostring(body) or "")
end)
end)
if ok4 then return end
local ok5 = pcall(function()
Http.post(targetUrl, jsonPayload, "", headers, function(code, body)
callback(tonumber(tostring(code)) or 0, body and tostring(body) or "")
end)
end)
if ok5 then return end
local ok3 = pcall(function()
Http.post(targetUrl, jsonPayload, function(code, body)
callback(tonumber(tostring(code)) or 0, body and tostring(body) or "")
end)
end)
if not ok3 then
callback(0, "")
end
end
local function showRestartDialog()
local dRestart = LuaDialog(service)
dRestart.setTitle("Restart")
dRestart.setMessage("Silakan Anda buka ulang ekstensi")
dRestart.setCancelable(false)
dRestart.setPositiveButton("OK", function()
pcall(function() dRestart.dismiss() end)
closeExtensionCompletely()
end)
dRestart.show()
safeSpeak("Silakan Anda buka ulang ekstensi")
end
local function downloadAndInstallUpdate(dUpdate, serverVer)
safeSpeak("Mengunduh pembaruan")
local scriptCdns = {
"https://cdn.jsdelivr.net/gh/" .. GITHUB_OWNER .. "/" .. GITHUB_REPO .. "@" .. GITHUB_BRANCH .. "/main.lua",
"https://fastly.jsdelivr.net/gh/" .. GITHUB_OWNER .. "/" .. GITHUB_REPO .. "@" .. GITHUB_BRANCH .. "/main.lua"
}
fetchGithubResource(UPDATE_SCRIPT_URL, API_SCRIPT_URL, scriptCdns, function(statusCode, body)
local scriptContent = body and tostring(body) or ""
local trimmedScript = trimText(scriptContent)
if statusCode == 200 and #trimmedScript > 100 and not trimmedScript:find("^<!DOCTYPE") and not trimmedScript:find("^<html") then
local loader = loadstring or load
local fn = loader(scriptContent)
if not fn then
safeSpeak("File skrip di server tidak valid")
return
end
if serverVer and #serverVer > 0 then
local patched, count = scriptContent:gsub('(local%s+CURRENT_VERSION%s*=%s*)"[^"]*"', '%1"' .. serverVer .. '"', 1)
if count and count > 0 then
scriptContent = patched
end
end
local candidatePaths = resolveCurrentScriptPaths()
local savedCount = 0
for _, path in ipairs(candidatePaths) do
local checkFile = io.open(path, "r")
if checkFile then
checkFile:close()
if writeTextToFile(path, scriptContent) then
savedCount = savedCount + 1
end
end
end
if savedCount == 0 and #candidatePaths > 0 then
if writeTextToFile(candidatePaths[1], scriptContent) then
savedCount = 1
end
end
if savedCount > 0 then
_G.IS_UPDATE_DIALOG_OPEN = false
if dUpdate then
pcall(function() dUpdate.dismiss() end)
end
showRestartDialog()
else
safeSpeak("Gagal menyimpan file pembaruan ke penyimpanan")
end
else
safeSpeak("Gagal mengunduh skrip pembaruan dari server")
end
end)
end
local function showUpdateDialog(serverVer, updateMsg)
if _G.IS_UPDATE_DIALOG_OPEN then return end
_G.IS_UPDATE_DIALOG_OPEN = true
local scroll = ScrollView(service)
local lay = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
scroll.addView(lay)
local tvCurr = TextView(service)
tvCurr.setText("Versi saat ini: " .. CURRENT_VERSION)
tvCurr.setPadding(0, 0, 0, 8)
lay.addView(tvCurr)
local tvServ = TextView(service)
tvServ.setText("Versi dari server: " .. serverVer)
tvServ.setPadding(0, 0, 0, 20)
lay.addView(tvServ)
local tvMsgCollapsed = TextView(service)
tvMsgCollapsed.setText(updateMsg)
tvMsgCollapsed.setPadding(0, 0, 0, 20)
lay.addView(tvMsgCollapsed)
local btnToggle = Button(service)
btnToggle.setText("Luaskan")
lay.addView(btnToggle)
local layLines = LinearLayout(service).setOrientation(1)
layLines.setPadding(0, 16, 0, 10)
layLines.setVisibility(View.GONE)
lay.addView(layLines)
for line in (updateMsg .. "\n"):gmatch("(.-)\n") do
local cleanLine = trimText(line)
if #cleanLine > 0 then
local tvLine = TextView(service)
tvLine.setText(cleanLine)
tvLine.setPadding(0, 8, 0, 8)
tvLine.setFocusable(true)
layLines.addView(tvLine)
end
end
local isExpanded = false
btnToggle.setOnClickListener(function()
isExpanded = not isExpanded
if isExpanded then
tvMsgCollapsed.setVisibility(View.GONE)
layLines.setVisibility(View.VISIBLE)
btnToggle.setText("Ciutkan")
else
layLines.setVisibility(View.GONE)
tvMsgCollapsed.setVisibility(View.VISIBLE)
btnToggle.setText("Luaskan")
end
end)
local dUpdate = LuaDialog(service)
dUpdate.setTitle("Pembaruan tersedia")
dUpdate.setView(scroll)
dUpdate.setCancelable(false)
dUpdate.setPositiveButton("Install", function()
downloadAndInstallUpdate(dUpdate, serverVer)
end)
dUpdate.setNegativeButton("Batal", function()
_G.IS_UPDATE_DIALOG_OPEN = false
pcall(function() dUpdate.dismiss() end)
closeExtensionCompletely()
end)
dUpdate.show()
safeSpeak("Pembaruan tersedia, versi " .. serverVer)
end
local function checkForUpdates(isManual)
if isManual then
safeSpeak("Memeriksa pembaruan")
end
local verCdns = {
"https://cdn.jsdelivr.net/gh/" .. GITHUB_OWNER .. "/" .. GITHUB_REPO .. "@" .. GITHUB_BRANCH .. "/version.txt",
"https://fastly.jsdelivr.net/gh/" .. GITHUB_OWNER .. "/" .. GITHUB_REPO .. "@" .. GITHUB_BRANCH .. "/version.txt"
}
local msgCdns = {
"https://cdn.jsdelivr.net/gh/" .. GITHUB_OWNER .. "/" .. GITHUB_REPO .. "@" .. GITHUB_BRANCH .. "/pesan%20pembaruan.txt",
"https://fastly.jsdelivr.net/gh/" .. GITHUB_OWNER .. "/" .. GITHUB_REPO .. "@" .. GITHUB_BRANCH .. "/pesan%20pembaruan.txt"
}
fetchGithubResource(UPDATE_VERSION_URL, API_VERSION_URL, verCdns, function(statusCode, body)
local rawVer = trimText(body)
local serverVer = trimText(rawVer:match("^([^\r\n]+)") or rawVer)
if statusCode == 200 and #serverVer > 0 and #serverVer < 32 and not serverVer:find("<") then
if serverVer ~= CURRENT_VERSION then
fetchGithubResource(UPDATE_MESSAGE_URL, API_MESSAGE_URL, msgCdns, function(mStatus, mBody)
local updateMsg = "Pembaruan versi " .. serverVer .. " tersedia."
if mStatus == 200 and mBody then
local cleanedMsg = trimText(mBody)
if #cleanedMsg > 0 and not cleanedMsg:find("^<!DOCTYPE") and not cleanedMsg:find("^<html") then
updateMsg = cleanedMsg
end
end
showUpdateDialog(serverVer, updateMsg)
end)
else
if isManual then
safeSpeak("Tidak ada pembaruan, Anda menggunakan versi terbaru.")
end
end
else
if isManual then
if statusCode == 401 or statusCode == 403 then
safeSpeak("Akses ditolak. Pastikan Token GitHub repositori privat sudah benar.")
elseif statusCode == 404 then
safeSpeak("Repositori privat atau file versi tidak ditemukan. Periksa token GitHub Anda.")
elseif statusCode > 0 then
safeSpeak("Gagal memeriksa pembaruan, kode status " .. tostring(statusCode))
else
safeSpeak("Gagal memeriksa pembaruan, periksa koneksi internet Anda.")
end
end
end
end)
end
local BACKUP_MASTER_SECRET = "INPUT_SUARA_AI_ULTRA::AES256::SHIELD::V1"
local function deriveBackupKeys(saltBytes)
local passChars = String(BACKUP_MASTER_SECRET).toCharArray()
local spec = PBEKeySpec(passChars, saltBytes, 65536, 512)
local factory = nil
local okSha256 = pcall(function()
factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256")
end)
if not okSha256 or not factory then
factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1")
end
local fullKeyBytes = factory.generateSecret(spec).getEncoded()
local aesKey = SecretKeySpec(fullKeyBytes, 0, 32, "AES")
local macKey = SecretKeySpec(fullKeyBytes, 32, 32, "HmacSHA256")
return aesKey, macKey
end
local function encryptBackupPayload(plainJson)
local ok, result = pcall(function()
local sr = SecureRandom()
local salt = luajava.newArray(Byte.TYPE, 16)
local iv = luajava.newArray(Byte.TYPE, 16)
sr.nextBytes(salt)
sr.nextBytes(iv)
local aesKey, macKey = deriveBackupKeys(salt)
local cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
cipher.init(Cipher.ENCRYPT_MODE, aesKey, IvParameterSpec(iv))
local cipherBytes = cipher.doFinal(String(plainJson).getBytes("UTF-8"))
local mac = Mac.getInstance("HmacSHA256")
mac.init(macKey)
mac.update(salt)
mac.update(iv)
local tagBytes = mac.doFinal(cipherBytes)
return cjson.encode({
format = "ISAU_ENC_V1",
cipher = "AES-256-CBC-HMAC-SHA256",
salt = tostring(Base64.encodeToString(salt, Base64.NO_WRAP)),
iv = tostring(Base64.encodeToString(iv, Base64.NO_WRAP)),
mac = tostring(Base64.encodeToString(tagBytes, Base64.NO_WRAP)),
data = tostring(Base64.encodeToString(cipherBytes, Base64.NO_WRAP))
})
end)
return ok and result or nil
end
local function decryptBackupPayload(encryptedContent)
local ok, plainText = pcall(function()
local env = cjson.decode(trimText(encryptedContent))
if type(env) ~= "table" or env.format ~= "ISAU_ENC_V1" then
return nil
end
local salt = Base64.decode(tostring(env.salt), Base64.DEFAULT)
local iv = Base64.decode(tostring(env.iv), Base64.DEFAULT)
local tagBytes = Base64.decode(tostring(env.mac), Base64.DEFAULT)
local cipherBytes = Base64.decode(tostring(env.data), Base64.DEFAULT)
local aesKey, macKey = deriveBackupKeys(salt)
local mac = Mac.getInstance("HmacSHA256")
mac.init(macKey)
mac.update(salt)
mac.update(iv)
local expectedTag = mac.doFinal(cipherBytes)
if not MessageDigest.isEqual(expectedTag, tagBytes) then
return nil
end
local cipher = Cipher.getInstance("AES/CBC/PKCS5Padding")
cipher.init(Cipher.DECRYPT_MODE, aesKey, IvParameterSpec(iv))
local decryptedBytes = cipher.doFinal(cipherBytes)
return tostring(String(decryptedBytes, "UTF-8"))
end)
return ok and plainText or nil
end
local function isSensitiveCredentialKey(key)
local kLower = tostring(key):lower()
return kLower:find("api_key", 1, true) ~= nil
or kLower:find("apikey", 1, true) ~= nil
or kLower:find("token", 1, true) ~= nil
end
local function performBackupToFile()
local allPrefs = prefs.getAll()
local exportData = {}
local excludedKeys = {
ai_custom_api_key = true,
github_private_token = true,
saved_media_vol = true,
is_running_nonstop = true,
is_recording_exp = true
}
local it = allPrefs.entrySet().iterator()
while it.hasNext() do
local entry = it.next()
local k = tostring(entry.getKey())
if not excludedKeys[k] and not isSensitiveCredentialKey(k) then
local v = entry.getValue()
local vStr = tostring(v)
local className = tostring(v.getClass().getSimpleName())
if className == "Boolean" then
exportData[k] = { t = "boolean", v = (vStr == "true") }
elseif className == "Integer" or className == "Long" then
exportData[k] = { t = "number", v = tonumber(vStr) or 0 }
else
exportData[k] = { t = "string", v = vStr }
end
end
end
local envelope = {
app = "Input Suara AI Ultra",
version = CURRENT_VERSION,
timestamp = os.time(),
settings = exportData
}
local plainJson = cjson.encode(envelope)
local encryptedText = encryptBackupPayload(plainJson)
if not encryptedText then
safeSpeak("Gagal mengenkripsi data cadangan")
return
end
local saved = false
for _, path in ipairs(BACKUP_FILE_PATHS) do
if writeTextToFile(path, encryptedText) then
saved = true
break
end
end
if saved then
safeSpeak("Seluruh pengaturan berhasil dicadangkan ke file dengan enkripsi tinggi. Kunci API Anda tidak ikut dicadangkan.")
else
safeSpeak("Gagal menyimpan file cadangan ke penyimpanan")
end
end
local function performRestoreFromFile()
local rawFileContent = nil
for _, path in ipairs(BACKUP_FILE_PATHS) do
local data = readTextFromFile(path)
if data and #trimText(data) > 0 then
rawFileContent = data
break
end
end
if not rawFileContent then
safeSpeak("File cadangan tidak ditemukan")
return
end
local decryptedJson = decryptBackupPayload(rawFileContent)
if not decryptedJson then
safeSpeak("Gagal memulihkan data, file cadangan rusak atau tidak valid")
return
end
local ok, envelope = pcall(cjson.decode, decryptedJson)
if not ok or type(envelope) ~= "table" or type(envelope.settings) ~= "table" then
safeSpeak("Format data cadangan tidak valid")
return
end
local existingApiKey = getPref("ai_custom_api_key", "")
local existingGithubToken = getPref("github_private_token", "")
local editor = prefs.edit()
editor.clear()
for k, item in pairs(envelope.settings) do
if not isSensitiveCredentialKey(k) and type(item) == "table" then
if item.t == "boolean" then
editor.putBoolean(k, item.v == true)
elseif item.t == "number" then
editor.putInt(k, math.floor(tonumber(item.v) or 0))
elseif item.t == "string" then
editor.putString(k, tostring(item.v or ""))
end
end
end
if #existingApiKey > 0 then
editor.putString("ai_custom_api_key", existingApiKey)
end
if #existingGithubToken > 0 then
editor.putString("github_private_token", existingGithubToken)
end
editor.apply()
safeSpeak("Seluruh pengaturan berhasil dipulihkan dari file")
end
local function muteMediaIfEnabled()
if getPref("audio_mute_media", false) and audioManager then
pcall(function()
local curVol = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
if curVol > 0 then
setPref("saved_media_vol", curVol)
audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, 0, 0)
end
end)
end
end
local function restoreMediaVolume()
local savedVol = getPref("saved_media_vol", -1)
if savedVol >= 0 and audioManager then
pcall(function()
audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, savedVol, 0)
end)
setPref("saved_media_vol", -1)
end
end
local function playBeep(isStart)
pcall(function()
local tg = ToneGenerator(AudioManager.STREAM_NOTIFICATION, 100)
if isStart then
tg.startTone(ToneGenerator.TONE_PROP_BEEP, 200)
else
tg.startTone(ToneGenerator.TONE_PROP_BEEP2, 260)
end
mainHandler.postDelayed(Runnable({
run = function()
pcall(function() tg.release() end)
end
}), 450)
end)
end
local function createSwitch(layout, text, key, defVal, onChange)
local sw = Switch(service)
sw.setText(text)
sw.setChecked(getPref(key, defVal))
sw.setOnClickListener(function()
setPref(key, sw.isChecked())
if onChange then onChange(sw.isChecked()) end
end)
layout.addView(sw)
return sw
end
local function createButton(layout, text, onClick)
local btn = Button(service)
btn.setText(text)
btn.setOnClickListener(onClick)
layout.addView(btn)
return btn
end
local function createEditText(layout, hint)
local et = EditText(service)
et.setHint(hint)
layout.addView(et)
return et
end
local function showListManager(title, prefKey)
local data = loadJSON(prefKey)
local items, keys = {}, {}
for k, v in pairs(data) do
table.insert(items, k .. " -> " .. v)
table.insert(keys, k)
end
local lv = ListView(service)
lv.setAdapter(ArrayAdapter(service, android.R.layout.simple_list_item_1, items))
local d = LuaDialog(service)
d.setTitle(title)
d.setView(lv)
d.setNegativeButton("Kembali", nil)
lv.onItemLongClick = function(l, v, p, id)
local key = keys[p + 1]
data[key] = nil
saveJSON(prefKey, data)
safeSpeak("Dihapus")
d.dismiss()
return true
end
d.show()
end
local function openLanguagePicker(title, prefKey, btnElement)
local lay = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
local etSearch = createEditText(lay, "Cari Bahasa...")
local lv = ListView(service)
lay.addView(lv)
local langList, langCodes = {}, {}
local locales = Locale.getAvailableLocales()
local len = Array.getLength(locales)
for i = 0, len - 1 do
local loc = Array.get(locales, i)
if loc.getDisplayLanguage() ~= "" then
table.insert(langList, loc.getDisplayName())
table.insert(langCodes, loc.toString())
end
end
local adapter = ArrayAdapter(service, android.R.layout.simple_list_item_1, langList)
lv.setAdapter(adapter)
etSearch.addTextChangedListener(luajava.createProxy("android.text.TextWatcher", {
onTextChanged = function(s) adapter.getFilter().filter(s) end,
beforeTextChanged = function() end,
afterTextChanged = function() end
}))
local d = LuaDialog(service).setTitle(title).setView(lay).setNegativeButton("Kembali", nil)
lv.onItemClick = function(l, v, p, id)
local selectedName = tostring(adapter.getItem(p))
local realIndex = 1
for idx, name in ipairs(langList) do
if name == selectedName then
realIndex = idx
break
end
end
setPref(prefKey, langCodes[realIndex])
setPref(prefKey .. "_name", selectedName)
if btnElement then
local prefix = (prefKey == "lang_recognizer") and "Pilih Bahasa Pengenal: " or "Pilih Bahasa Terjemahan: "
btnElement.setText(prefix .. selectedName)
end
local speakPrefix = (prefKey == "lang_recognizer") and "Bahasa pengenal " or "Bahasa terjemahan "
safeSpeak(speakPrefix .. selectedName .. " dipilih")
d.dismiss()
end
d.show()
end
local function menuUmum()
local scroll = ScrollView(service)
local lay = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
scroll.addView(lay)
createSwitch(lay, "Auto Salin ke Papan Klip", "umum_autocopy", false)
createSwitch(lay, "Auto Nonstop (Listening terus menerus)", "umum_nonstop", false)
createSwitch(lay, "Bahasa Campuran", "umum_mixed", false)
createSwitch(lay, "Mode Bisik-bisik (Whisper)", "umum_whisper", false)
local divider = View(service)
divider.setMinimumHeight(3)
divider.setBackgroundColor(0xFFCCCCCC)
lay.addView(divider)
local currEmojiLevel = getPref("umum_emoji_level", "Sedang")
local btnEmojiLevel = Button(service)
btnEmojiLevel.setText("Emoji Level: " .. currEmojiLevel)
btnEmojiLevel.setVisibility(getPref("umum_emoji_mode", false) and View.VISIBLE or View.GONE)
btnEmojiLevel.setOnClickListener(function()
local lv = ListView(service)
lv.setAdapter(ArrayAdapter(service, android.R.layout.simple_list_item_1, EMOJI_LEVELS))
local dLvl = LuaDialog(service).setTitle("Pilih Emoji Level").setView(lv).setNegativeButton("Kembali", nil)
lv.onItemClick = function(l, v, p, id)
local selectedLvl = EMOJI_LEVELS[p + 1]
setPref("umum_emoji_level", selectedLvl)
btnEmojiLevel.setText("Emoji Level: " .. selectedLvl)
safeSpeak("Emoji level " .. selectedLvl .. " dipilih")
dLvl.dismiss()
end
dLvl.show()
end)
createSwitch(lay, "Emoji Mode", "umum_emoji_mode", false, function(isChecked)
btnEmojiLevel.setVisibility(isChecked and View.VISIBLE or View.GONE)
end)
lay.addView(btnEmojiLevel)
createSwitch(lay, "Filter Duplikasi", "umum_filter_duplikasi", false)
local currCaseMode = getPref("umum_case_mode", "Normal")
local btnCaseMode = Button(service)
btnCaseMode.setText("Pemrosesan Huruf: " .. currCaseMode)
btnCaseMode.setOnClickListener(function()
local lv = ListView(service)
lv.setAdapter(ArrayAdapter(service, android.R.layout.simple_list_item_1, CASE_MODES))
local dCase = LuaDialog(service).setTitle("Pemrosesan Huruf").setView(lv).setNegativeButton("Kembali", nil)
lv.onItemClick = function(l, v, p, id)
local selectedCase = CASE_MODES[p + 1]
setPref("umum_case_mode", selectedCase)
btnCaseMode.setText("Pemrosesan Huruf: " .. selectedCase)
safeSpeak("Pemrosesan huruf " .. selectedCase .. " dipilih")
dCase.dismiss()
end
dCase.show()
end)
lay.addView(btnCaseMode)
LuaDialog(service).setTitle("Umum").setView(scroll).setNegativeButton("Kembali", nil).show()
end
local function getAvailableGeminiModels()
local rawJson = getPref("ai_gemini_fetched_models", "")
if #rawJson > 0 then
local ok, list = pcall(cjson.decode, rawJson)
if ok and type(list) == "table" and #list > 0 then
return list
end
end
return DEFAULT_GEMINI_MODELS
end
local function openApiKeyDialog()
local lay = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
local tvHeader = TextView(service)
tvHeader.setText("Atur Kunci API")
tvHeader.setPadding(0, 0, 0, 16)
tvHeader.setFocusable(true)
lay.addView(tvHeader)
local etKey = EditText(service)
etKey.setHint("Masukkan Kunci API Google Gemini...")
etKey.setText(getPref("ai_custom_api_key", ""))
lay.addView(etKey)
LuaDialog(service).setTitle("Atur Kunci API").setView(lay)
.setPositiveButton("Simpan", function()
local newKey = trimText(etKey.getText().toString())
setPref("ai_custom_api_key", newKey)
if #newKey > 0 then
safeSpeak("Kunci API tersimpan")
else
safeSpeak("Kunci API dikosongkan")
end
end)
.setNegativeButton("Batal", function()
safeSpeak("Dibatalkan")
end)
.show()
end
local function openCustomInstructionDialog()
local lay = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
local tvHeader = TextView(service)
tvHeader.setText("Atur Instruksi Khusus")
tvHeader.setPadding(0, 0, 0, 16)
tvHeader.setFocusable(true)
lay.addView(tvHeader)
local etInst = EditText(service)
etInst.setHint("Masukkan instruksi khusus AI...")
etInst.setText(getPref("ai_custom_inst_text", ""))
lay.addView(etInst)
LuaDialog(service).setTitle("Atur Instruksi Khusus").setView(lay)
.setPositiveButton("Simpan", function()
setPref("ai_custom_inst_text", trimText(etInst.getText().toString()))
safeSpeak("Instruksi khusus tersimpan")
end)
.setNegativeButton("Batal", function()
safeSpeak("Dibatalkan")
end)
.show()
end
local function menuPengaturanAI()
local scroll = ScrollView(service)
local lay = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
scroll.addView(lay)
local useCustomApi = getPref("ai_custom_api_use", false)
local layDefaultModel = LinearLayout(service).setOrientation(1)
layDefaultModel.setVisibility(useCustomApi and View.GONE or View.VISIBLE)
local currModel = getPref("ai_model", "gpt-sol")
local btnDefaultModel = Button(service)
btnDefaultModel.setText("Pilih Model AI: " .. currModel)
layDefaultModel.addView(btnDefaultModel)
btnDefaultModel.setOnClickListener(function()
local lv = ListView(service)
lv.setAdapter(ArrayAdapter(service, android.R.layout.simple_list_item_1, AI_MODELS))
local dModel = LuaDialog(service).setTitle("Pilih Model AI").setView(lv).setNegativeButton("Kembali", nil)
lv.onItemClick = function(l, v, p, id)
local selectedModel = AI_MODELS[p + 1]
setPref("ai_model", selectedModel)
btnDefaultModel.setText("Pilih Model AI: " .. selectedModel)
safeSpeak("Model " .. selectedModel .. " dipilih")
dModel.dismiss()
end
dModel.show()
end)
local layCustomApi = LinearLayout(service).setOrientation(1)
layCustomApi.setVisibility(useCustomApi and View.VISIBLE or View.GONE)
local btnAturApi = Button(service)
btnAturApi.setText("Atur Kunci API")
btnAturApi.setOnClickListener(function()
openApiKeyDialog()
end)
layCustomApi.addView(btnAturApi)
local currGeminiModel = getPref("ai_gemini_model", "Gemini Flash")
local btnGeminiModel = Button(service)
btnGeminiModel.setText("Pilih Model AI: " .. currGeminiModel)
layCustomApi.addView(btnGeminiModel)
btnGeminiModel.setOnClickListener(function()
local savedKey = trimText(getPref("ai_custom_api_key", ""))
if #savedKey == 0 then
safeSpeak("Model tidak tersedia, silakan atur kunci API terlebih dahulu")
return
end
local modelList = getAvailableGeminiModels()
local lv = ListView(service)
lv.setAdapter(ArrayAdapter(service, android.R.layout.simple_list_item_1, modelList))
local dGemModel = LuaDialog(service).setTitle("Pilih Model AI").setView(lv).setNegativeButton("Kembali", nil)
lv.onItemClick = function(l, v, p, id)
local chosen = modelList[p + 1]
setPref("ai_gemini_model", chosen)
btnGeminiModel.setText("Pilih Model AI: " .. chosen)
safeSpeak("Model " .. chosen .. " dipilih")
dGemModel.dismiss()
end
dGemModel.show()
end)
local btnRefreshModel = Button(service)
btnRefreshModel.setText("Refresh Model")
layCustomApi.addView(btnRefreshModel)
btnRefreshModel.setOnClickListener(function()
local activeKey = trimText(getPref("ai_custom_api_key", ""))
if #activeKey == 0 then
safeSpeak("Pastikan Anda sudah mengatur kunci API terlebih dahulu")
return
end
safeSpeak("Mengambil daftar model dari Google AI Studio")
local modelsUrl = GEMINI_API_BASE .. "?key=" .. urlencode(activeKey)
Http.get(modelsUrl, function(code, body)
local sc = tonumber(tostring(code)) or 0
if sc == 200 and body then
local ok, j = pcall(cjson.decode, tostring(body))
if ok and type(j) == "table" and type(j.models) == "table" then
local fetched = {}
for _, m in ipairs(j.models) do
local canGenerate = false
if type(m.supportedGenerationMethods) == "table" then
for _, method in ipairs(m.supportedGenerationMethods) do
if tostring(method) == "generateContent" then
canGenerate = true
break
end
end
else
canGenerate = true
end
if canGenerate and m.name then
local cleanName = tostring(m.name):gsub("^models/", "")
if cleanName:find("gemini", 1, true) then
table.insert(fetched, cleanName)
end
end
end
if #fetched > 0 then
saveJSON("ai_gemini_fetched_models", fetched)
safeSpeak("Berhasil memuat " .. tostring(#fetched) .. " model dari Google AI Studio")
return
end
end
end
safeSpeak("Gagal mengambil model, periksa kunci API atau koneksi internet Anda")
end)
end)
createSwitch(lay, "Custom Kunci API", "ai_custom_api_use", false, function(isChecked)
layDefaultModel.setVisibility(isChecked and View.GONE or View.VISIBLE)
layCustomApi.setVisibility(isChecked and View.VISIBLE or View.GONE)
end)
lay.addView(layDefaultModel)
lay.addView(layCustomApi)
local divider1 = View(service)
divider1.setMinimumHeight(3)
divider1.setBackgroundColor(0xFFCCCCCC)
lay.addView(divider1)
local currStyle = getPref("ai_style", "Normal")
local btnStyle = Button(service)
btnStyle.setText("Gaya Input Suara: " .. currStyle)
lay.addView(btnStyle)
btnStyle.setOnClickListener(function()
local lv = ListView(service)
lv.setAdapter(ArrayAdapter(service, android.R.layout.simple_list_item_1, AI_STYLES))
local dStyle = LuaDialog(service).setTitle("Pilih Gaya Input Suara").setView(lv).setNegativeButton("Kembali", nil)
lv.onItemClick = function(l, v, p, id)
local selectedStyle = AI_STYLES[p + 1]
setPref("ai_style", selectedStyle)
btnStyle.setText("Gaya Input Suara: " .. selectedStyle)
safeSpeak("Gaya " .. selectedStyle .. " dipilih")
dStyle.dismiss()
end
dStyle.show()
end)
local divider2 = View(service)
divider2.setMinimumHeight(3)
divider2.setBackgroundColor(0xFFCCCCCC)
lay.addView(divider2)
local btnAturInst = Button(service)
btnAturInst.setText("Atur Instruksi Khusus")
btnAturInst.setVisibility(getPref("ai_custom_inst_use", false) and View.VISIBLE or View.GONE)
btnAturInst.setOnClickListener(function()
openCustomInstructionDialog()
end)
createSwitch(lay, "Instruksi Khusus", "ai_custom_inst_use", false, function(isChecked)
btnAturInst.setVisibility(isChecked and View.VISIBLE or View.GONE)
end)
lay.addView(btnAturInst)
LuaDialog(service).setTitle("Pengaturan AI dan Model").setView(scroll).setNegativeButton("Kembali", nil).show()
end
local function menuPemrosesanAudio()
local scroll = ScrollView(service)
local lay = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
scroll.addView(lay)
local tvInfo = TextView(service)
tvInfo.setText("Jika dinonaktifkan, ekstensi menggunakan Input Suara Google standar. Jika diaktifkan, ekstensi merekam suara secara langsung dan berkelanjutan tanpa batas waktu dan tanpa menggunakan layanan Google Voice, lalu saat dihentikan rekaman langsung dikirim ke AI untuk ditranskripsikan.")
tvInfo.setPadding(0, 0, 0, 20)
lay.addView(tvInfo)
createSwitch(lay, "Gunakan pengenalan suara berkelanjutan, fitur ini menggunakan rekaman melewati voice input dari Google. Eksperimental", "audio_use_recorder", false)
createSwitch(lay, "Heningkan media saat mulai listening", "audio_mute_media", false)
LuaDialog(service).setTitle("Pemrosesan Audio").setView(scroll).setNegativeButton("Kembali", nil).show()
end
local function menuManajemenFitur()
local scroll = ScrollView(service)
local lay = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
scroll.addView(lay)
createSwitch(lay, "Auto Comeback (Ulangi jika gagal)", "fitur_comeback", false)
createSwitch(lay, "Umpan Balik Getaran", "fitur_vibrate", true)
createSwitch(lay, "Paksa Layar Menyala saat Listening", "fitur_wakelock", false)
createSwitch(lay, "Pembersihan Otomatis", "fitur_auto_clean", false)
LuaDialog(service).setTitle("Manajemen Fitur").setView(scroll).setNegativeButton("Kembali", nil).show()
end
local function menuFiturKhusus()
local scroll = ScrollView(service)
local lay = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
scroll.addView(lay)
local tvDesc = TextView(service)
tvDesc.setText("Pilih salah satu mode output teks. Pada Fake Link dan Fake Email, setiap spasi antar kata otomatis diubah menjadi titik (.) dengan akhiran domain pilihan.")
tvDesc.setPadding(0, 0, 0, 20)
lay.addView(tvDesc)
local currMode = getPref("khusus_mode", "normal")
local currLinkDomain = getPref("khusus_link_domain", ".com")
local currEmailDomain = getPref("khusus_email_domain", "@gmail.com")
local swNormal = Switch(service)
swNormal.setText("Normal")
swNormal.setChecked(currMode == "normal")
lay.addView(swNormal)
local swFakeLink = Switch(service)
swFakeLink.setText("Fake Link")
swFakeLink.setChecked(currMode == "fake_link")
lay.addView(swFakeLink)
local btnLinkDomain = Button(service)
btnLinkDomain.setText("Pilih Domain Link: " .. currLinkDomain)
btnLinkDomain.setVisibility(currMode == "fake_link" and View.VISIBLE or View.GONE)
lay.addView(btnLinkDomain)
local swFakeEmail = Switch(service)
swFakeEmail.setText("Fake Email")
swFakeEmail.setChecked(currMode == "fake_email")
lay.addView(swFakeEmail)
local btnEmailDomain = Button(service)
btnEmailDomain.setText("Pilih Domain Email: " .. currEmailDomain)
btnEmailDomain.setVisibility(currMode == "fake_email" and View.VISIBLE or View.GONE)
lay.addView(btnEmailDomain)
local function applyModeSelection(selectedMode)
setPref("khusus_mode", selectedMode)
swNormal.setChecked(selectedMode == "normal")
swFakeLink.setChecked(selectedMode == "fake_link")
swFakeEmail.setChecked(selectedMode == "fake_email")
btnLinkDomain.setVisibility(selectedMode == "fake_link" and View.VISIBLE or View.GONE)
btnEmailDomain.setVisibility(selectedMode == "fake_email" and View.VISIBLE or View.GONE)
end
swNormal.setOnClickListener(function()
applyModeSelection("normal")
safeSpeak("Mode normal dipilih")
end)
swFakeLink.setOnClickListener(function()
if swFakeLink.isChecked() then
applyModeSelection("fake_link")
safeSpeak("Fake link diaktifkan")
else
applyModeSelection("normal")
safeSpeak("Mode normal dipilih")
end
end)
swFakeEmail.setOnClickListener(function()
if swFakeEmail.isChecked() then
applyModeSelection("fake_email")
safeSpeak("Fake email diaktifkan")
else
applyModeSelection("normal")
safeSpeak("Mode normal dipilih")
end
end)
btnLinkDomain.setOnClickListener(function()
local lv = ListView(service)
lv.setAdapter(ArrayAdapter(service, android.R.layout.simple_list_item_1, FAKE_LINK_DOMAINS))
local dDom = LuaDialog(service).setTitle("Pilih Domain Link").setView(lv).setNegativeButton("Kembali", nil)
lv.onItemClick = function(l, v, p, id)
local chosen = FAKE_LINK_DOMAINS[p + 1]
setPref("khusus_link_domain", chosen)
btnLinkDomain.setText("Pilih Domain Link: " .. chosen)
safeSpeak("Domain " .. chosen .. " dipilih")
dDom.dismiss()
end
dDom.show()
end)
btnEmailDomain.setOnClickListener(function()
local lv = ListView(service)
lv.setAdapter(ArrayAdapter(service, android.R.layout.simple_list_item_1, FAKE_EMAIL_DOMAINS))
local dDom = LuaDialog(service).setTitle("Pilih Domain Email").setView(lv).setNegativeButton("Kembali", nil)
lv.onItemClick = function(l, v, p, id)
local chosen = FAKE_EMAIL_DOMAINS[p + 1]
setPref("khusus_email_domain", chosen)
btnEmailDomain.setText("Pilih Domain Email: " .. chosen)
safeSpeak("Domain " .. chosen .. " dipilih")
dDom.dismiss()
end
dDom.show()
end)
LuaDialog(service).setTitle("Fitur Khusus").setView(scroll).setNegativeButton("Kembali", nil).show()
end
local function menuManajemenKamus()
local scroll = ScrollView(service)
local lay = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
scroll.addView(lay)
local swKamus = createSwitch(lay, "Gunakan Kamus", "kamus_use", false)
createSwitch(lay, "Gunakan Ekspresi Reguler", "kamus_regex", false)
createButton(lay, "Tambah Entri", function()
local layAdd = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
local etOri = createEditText(layAdd, "Cari (Kata Original)")
local etGanti = createEditText(layAdd, "Kata Pengganti")
LuaDialog(service).setTitle("Tambah Kamus").setView(layAdd)
.setPositiveButton("OK", function()
local k = trimText(etOri.getText().toString())
local v = etGanti.getText().toString()
if #k > 0 then
local data = loadJSON("data_kamus")
data[k] = v
saveJSON("data_kamus", data)
setPref("kamus_use", true)
pcall(function() swKamus.setChecked(true) end)
safeSpeak("Kamus tersimpan dan diaktifkan")
end
end)
.setNegativeButton("Batal", nil).show()
end)
createButton(lay, "Kumpulan Kamus", function() showListManager("Kumpulan Kamus", "data_kamus") end)
LuaDialog(service).setTitle("Manajemen Kamus").setView(scroll).setNegativeButton("Kembali", nil).show()
end
local function menuManajemenPemblokiran()
local scroll = ScrollView(service)
local lay = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
scroll.addView(lay)
local swBlokir = createSwitch(lay, "Gunakan Manajemen Pemblokiran", "blokir_use", false)
createSwitch(lay, "Gunakan Ekspresi Reguler", "blokir_regex", false)
createButton(lay, "Tambah Entri", function()
local layAdd = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
local etOri = createEditText(layAdd, "Kata yang diblokir")
LuaDialog(service).setTitle("Tambah Pemblokiran").setView(layAdd)
.setPositiveButton("Oke", function()
local k = trimText(etOri.getText().toString())
if #k > 0 then
local data = loadJSON("data_blokir")
data[k] = "BLOKIR"
saveJSON("data_blokir", data)
setPref("blokir_use", true)
pcall(function() swBlokir.setChecked(true) end)
safeSpeak("Pemblokiran tersimpan dan diaktifkan")
end
end)
.setNegativeButton("Batal", nil).show()
end)
createButton(lay, "Kumpulan Kata Diblokir", function() showListManager("Daftar Pemblokiran", "data_blokir") end)
LuaDialog(service).setTitle("Manajemen Pemblokiran").setView(scroll).setNegativeButton("Kembali", nil).show()
end
local function menuTransisiBranding()
local scroll = ScrollView(service)
local lay = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
scroll.addView(lay)
local tv1 = TextView(service); tv1.setText("Transisi Awal:"); lay.addView(tv1)
createSwitch(lay, "Spasi Awal", "brand_start_space", false)
createSwitch(lay, "Baris Baru (Enter) Awal", "brand_start_newline", false)
local et1 = createEditText(lay, "Isi custom transisi awal...")
et1.setText(getPref("brand_start_text", ""))
et1.setVisibility(getPref("brand_start_custom", false) and View.VISIBLE or View.GONE)
createSwitch(lay, "Custom Branding Awal", "brand_start_custom", false, function(isChecked)
et1.setVisibility(isChecked and View.VISIBLE or View.GONE)
end)
local divider = View(service); divider.setMinimumHeight(3); divider.setBackgroundColor(0xFFCCCCCC); lay.addView(divider)
local tv2 = TextView(service); tv2.setText("\nTransisi Akhir:"); lay.addView(tv2)
createSwitch(lay, "Spasi Akhir", "brand_end_space", false)
createSwitch(lay, "Baris Baru (Enter) Akhir", "brand_end_newline", false)
local et2 = createEditText(lay, "Isi custom transisi akhir...")
et2.setText(getPref("brand_end_text", ""))
et2.setVisibility(getPref("brand_end_custom", false) and View.VISIBLE or View.GONE)
createSwitch(lay, "Custom Branding Akhir", "brand_end_custom", false, function(isChecked)
et2.setVisibility(isChecked and View.VISIBLE or View.GONE)
end)
LuaDialog(service).setTitle("Transisi Branding").setView(scroll)
.setPositiveButton("Simpan", function()
setPref("brand_start_text", et1.getText().toString())
setPref("brand_end_text", et2.getText().toString())
safeSpeak("Tersimpan")
end)
.setNegativeButton("Kembali", nil).show()
end
local function menuPengaturanBahasa()
local scroll = ScrollView(service)
local lay = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
scroll.addView(lay)
local currRecName = getPref("lang_recognizer_name", "")
local btnRecText = "Pilih Bahasa Pengenal" .. (currRecName ~= "" and (": " .. currRecName) or "")
local btnRec = Button(service)
btnRec.setText(btnRecText)
lay.addView(btnRec)
btnRec.setOnClickListener(function()
openLanguagePicker("Pilih Bahasa Pengenal", "lang_recognizer", btnRec)
end)
local divider = View(service)
divider.setMinimumHeight(3)
divider.setBackgroundColor(0xFFCCCCCC)
lay.addView(divider)
createSwitch(lay, "Aktifkan Terjemahan (Butuh Internet)", "lang_translate_use", false)
local currTransName = getPref("lang_translate_target_name", "")
local btnTransText = "Pilih Bahasa Terjemahan" .. (currTransName ~= "" and (": " .. currTransName) or "")
local btnTrans = Button(service)
btnTrans.setText(btnTransText)
lay.addView(btnTrans)
btnTrans.setOnClickListener(function()
openLanguagePicker("Pilih Bahasa Terjemahan", "lang_translate_target", btnTrans)
end)
LuaDialog(service).setTitle("Pengaturan Bahasa").setView(scroll).setNegativeButton("Kembali", nil).show()
end
local function menuPencadanganPemulihan()
local scroll = ScrollView(service)
local lay = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
scroll.addView(lay)
createButton(lay, "Cadangkan Data", function()
local dConfirm = LuaDialog(service)
dConfirm.setTitle("Cadangkan Data")
dConfirm.setMessage("Apakah Anda ingin mencadangkan data ke file? Tenang saja, kunci API Anda tidak akan tercadangkan.")
dConfirm.setPositiveButton("Cadangkan", function()
performBackupToFile()
end)
dConfirm.setNegativeButton("Batal", nil)
dConfirm.show()
safeSpeak("Apakah Anda ingin mencadangkan data ke file? Tenang saja, kunci API Anda tidak akan tercadangkan.")
end)
createButton(lay, "Pulihkan Data dari File", function()
local dConfirm = LuaDialog(service)
dConfirm.setTitle("Pulihkan Data dari File")
dConfirm.setMessage("Apakah Anda ingin memulihkan data dari file?")
dConfirm.setPositiveButton("Pulihkan", function()
performRestoreFromFile()
end)
dConfirm.setNegativeButton("Batal", nil)
dConfirm.show()
safeSpeak("Apakah Anda ingin memulihkan data dari file?")
end)
LuaDialog(service).setTitle("Pencadangan dan Pemulihan").setView(scroll).setNegativeButton("Kembali", nil).show()
end
local function openGithubTokenDialog()
local lay = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
local tvHeader = TextView(service)
tvHeader.setText("Token GitHub (Opsional untuk Repositori Privat)")
tvHeader.setPadding(0, 0, 0, 16)
tvHeader.setFocusable(true)
lay.addView(tvHeader)
local etToken = EditText(service)
etToken.setHint("Tempel Personal Access Token GitHub...")
etToken.setText(getPref("github_private_token", ""))
lay.addView(etToken)
LuaDialog(service).setTitle("Token GitHub").setView(lay)
.setPositiveButton("Simpan", function()
local token = trimText(etToken.getText().toString())
setPref("github_private_token", token)
if #token > 0 then
safeSpeak("Token GitHub tersimpan")
else
safeSpeak("Token GitHub dikosongkan")
end
end)
.setNegativeButton("Batal", function()
safeSpeak("Dibatalkan")
end)
.show()
end
local function menuTentangDeveloper()
local scroll = ScrollView(service)
local lay = LinearLayout(service).setOrientation(1).setPadding(40, 40, 40, 40)
scroll.addView(lay)
local tvDev = TextView(service)
tvDev.setText("Developer by Abil Maulid Al-Fatah\nVersi: " .. CURRENT_VERSION)
tvDev.setPadding(0, 10, 0, 24)
tvDev.setFocusable(true)
lay.addView(tvDev)
local dDev = LuaDialog(service)
dDev.setTitle("Tentang Developer")
dDev.setView(scroll)
dDev.setNegativeButton("Kembali", nil)
createButton(lay, "Subscribe YouTube Channel", function()
pcall(function() dDev.dismiss() end)
openExternalLink(YOUTUBE_URL)
end)
createButton(lay, "Join Telegram Channel", function()
pcall(function() dDev.dismiss() end)
openExternalLink(TELEGRAM_URL)
end)
createButton(lay, "Atur Token GitHub (Repo Privat)", function()
openGithubTokenDialog()
end)
createButton(lay, "Periksa Pembaruan", function()
checkForUpdates(true)
end)
dDev.show()
end
local function bukaPengaturanUtama()
local menuItems = {
"Umum",
"Pengaturan AI dan Model",
"Pemrosesan Audio",
"Manajemen Fitur",
"Fitur Khusus",
"Manajemen Kamus",
"Manajemen Pemblokiran",
"Transisi Branding",
"Pengaturan Bahasa",
"Pencadangan dan Pemulihan",
"Tentang Developer"
}
local funcs = {
menuUmum,
menuPengaturanAI,
menuPemrosesanAudio,
menuManajemenFitur,
menuFiturKhusus,
menuManajemenKamus,
menuManajemenPemblokiran,
menuTransisiBranding,
menuPengaturanBahasa,
menuPencadanganPemulihan,
menuTentangDeveloper
}
local lv = ListView(service)
lv.setAdapter(ArrayAdapter(service, android.R.layout.simple_list_item_1, menuItems))
local d = LuaDialog(service).setTitle("Pengaturan Input Suara AI Ultra").setView(lv).setNegativeButton("Kembali", nil)
_G.ACTIVE_MAIN_DIALOG = d
lv.onItemClick = function(l, v, p, id) funcs[p + 1]() end
d.show()
checkForUpdates(false)
end
local function getSortedKeysByLength(tbl)
local keys = {}
for k, _ in pairs(tbl) do
if k and #tostring(k) > 0 then
table.insert(keys, tostring(k))
end
end
table.sort(keys, function(a, b) return #a > #b end)
return keys
end
local function applyAutoCleanNoise(text)
if not getPref("fitur_auto_clean", false) then
return text
end
local t = tostring(text or "")
t = t:gsub("%[[^%]]-%]", " ")
t = t:gsub("%([^%)]-[Nn]oise[^%)]-%)", " ")
t = t:gsub("%([^%)]-[Mm]usik[^%)]-%)", " ")
t = t:gsub("%([^%)]-[Tt]ertawa[^%)]-%)", " ")
t = t:gsub("%*[^%*]-%*", " ")
t = t:gsub("[Tt]erima kasih telah menonton%.?", " ")
t = t:gsub("[Ss]ubtitles by[^%.%!%?]*%.?", " ")
t = t:gsub("[Ss]ubscribe[^%.%!%?]*%.?", " ")
t = t:gsub("[%z\1-\8\11-\12\14-\31]", "")
t = t:gsub("%.%.+%.?", ".")
t = t:gsub(",,+", ",")
t = t:gsub("%!%!+", "!")
t = t:gsub("%?%?+", "?")
t = t:gsub("  +", " ")
return trimText(t)
end
local function processTextLocal(text, isPostAI)
local t = tostring(text or "")
if #t == 0 then return t end
t = applyAutoCleanNoise(t)
if getPref("blokir_use", false) then
local data = loadJSON("data_blokir")
local useRegex = getPref("blokir_regex", false)
for _, k in ipairs(getSortedKeysByLength(data)) do
if useRegex then
pcall(function() t = t:gsub(k, "") end)
else
local pat = buildCaseInsensitivePattern(k)
pcall(function() t = t:gsub(pat, "") end)
end
end
end
if getPref("kamus_use", false) then
local data = loadJSON("data_kamus")
local useRegex = getPref("kamus_regex", false)
for _, k in ipairs(getSortedKeysByLength(data)) do
local v = tostring(data[k] or "")
local safeV = v:gsub("%%", "%%%%")
local skipPost = false
if isPostAI and not useRegex and #v > 0 then
if v:lower():find(k:lower(), 1, true) and t:lower():find(v:lower(), 1, true) then
skipPost = true
end
end
if not skipPost then
if useRegex then
pcall(function() t = t:gsub(k, v) end)
else
local pat = buildCaseInsensitivePattern(k)
pcall(function() t = t:gsub(pat, safeV) end)
end
end
end
end
t = t:gsub("  +", " "):gsub("^%s+", ""):gsub("%s+$", "")
return t
end
local function applyDuplicateFilter(text)
if not getPref("umum_filter_duplikasi", false) then
return text
end
local t = tostring(text or "")
t = t:gsub("(%f[%a])([%a]+)%-([%a]+)(%f[^%a])", function(b1, w1, w2, b2)
if w1:lower() == w2:lower() then
return b1 .. w1 .. "2" .. b2
end
return b1 .. w1 .. "-" .. w2 .. b2
end)
t = t:gsub("(%f[%a])([%a]+)%s+([%a]+)(%f[^%a])", function(b1, w1, w2, b2)
if w1:lower() == w2:lower() then
return b1 .. w1 .. "2" .. b2
end
return nil
end)
return t
end
local function applyCaseProcessing(text)
local mode = getPref("umum_case_mode", "Normal")
local t = tostring(text or "")
if #t == 0 or mode == "Normal" then
return t
end
if mode == "Huruf Besar Semua" then
return t:upper()
elseif mode == "Huruf Kecil Semua" then
return t:lower()
elseif mode == "Kapitalisasi Otomatis" then
t = t:gsub("^(%s*)(%a)", function(sp, ch)
return sp .. ch:upper()
end)
t = t:gsub("([%.%!%?%n]+%s*)(%a)", function(sep, ch)
return sep .. ch:upper()
end)
return t
end
return t
end
local function applySpecialFeatureFormat(text)
local mode = getPref("khusus_mode", "normal")
if mode ~= "fake_link" and mode ~= "fake_email" then
return text
end
local raw = trimText(text)
if #raw == 0 then return text end
local words = {}
for token in raw:gmatch("%S+") do
local clean = token:gsub("^[^%w]+", ""):gsub("[^%w]+$", ""):gsub("[^%w%-_]+", ".")
clean = clean:gsub("%.%.+", "."):gsub("^%.+", ""):gsub("%.+$", "")
if #clean > 0 then
table.insert(words, clean:lower())
end
end
if #words == 0 then return text end
local joined = table.concat(words, ".")
if mode == "fake_link" then
local domain = getPref("khusus_link_domain", ".com")
if domain:sub(1, 1) ~= "." then domain = "." .. domain end
local escapedDom = escapePattern(domain)
if not joined:find(escapedDom .. "$") then
joined = joined .. domain
end
return joined
elseif mode == "fake_email" then
local domain = getPref("khusus_email_domain", "@gmail.com")
if domain:sub(1, 1) ~= "@" then domain = "@" .. domain end
local escapedDom = escapePattern(domain)
if not joined:find(escapedDom .. "$") then
joined = joined .. domain
end
return joined
end
return text
end
local function insertResultFinal(finalText, skipNonstopLoop, fallbackNode)
local step1 = processTextLocal(finalText, true)
local step2 = applyDuplicateFilter(step1)
local step3 = applyCaseProcessing(step2)
local formattedText = applySpecialFeatureFormat(step3)
local pre = ""
local post = ""
if getPref("brand_start_space", false) then pre = pre .. " " end
if getPref("brand_start_newline", false) then pre = pre .. "\n" end
if getPref("brand_start_custom", false) then pre = pre .. getPref("brand_start_text", "") end
if getPref("brand_end_space", false) then post = " " .. post end
if getPref("brand_end_newline", false) then post = post .. "\n" end
if getPref("brand_end_custom", false) then post = getPref("brand_end_text", "") .. post end
local txt = pre .. formattedText .. post
local isTranslated = getPref("lang_translate_use", false)
local node = service.getEditText() or fallbackNode
if node then
pcall(function() service.insertText(node, txt) end)
if getPref("fitur_vibrate", true) then vibrator.vibrate(40) end
if getPref("umum_autocopy", false) then pcall(function() service.copy(txt) end) end
if isTranslated then
safeSpeak(formattedText)
end
else
pcall(function() service.copy(txt) end)
if isTranslated then
safeSpeak(formattedText)
else
safeSpeak("Hasil disalin ke papan klip")
end
end
if not skipNonstopLoop and getPref("umum_nonstop", false) and getPref("is_running_nonstop", false) then
local nextDelay = isTranslated and 1400 or 500
mainHandler.postDelayed(Runnable({run = function() startVoiceInput() end}), nextDelay)
else
setPref("is_running_nonstop", false)
restoreMediaVolume()
if wakeLock and wakeLock.isHeld() then wakeLock.release() end
end
end
local function extractGeminiPartText(part)
if type(part) ~= "table" then return "" end
if type(part.audioTranscription) == "table" and part.audioTranscription.text then
return tostring(part.audioTranscription.text)
end
if part.text and not part.thought then
return tostring(part.text)
end
return ""
end
local function parseAIResponse(body)
if not body then return "" end
local trimmed = trimText(body)
if #trimmed == 0 then return "" end
if trimmed:find("data:") then
local chunks = {}
for line in trimmed:gmatch("[^\r\n]+") do
local d = line:match("^data:%s*(.+)$")
if d and d ~= "[DONE]" then
local ok, j = pcall(cjson.decode, d)
if ok and type(j) == "table" then
local piece = j.response or j.text or j.content or j.result
if not piece and j.choices and j.choices[1] then
if j.choices[1].delta and j.choices[1].delta.content then
piece = j.choices[1].delta.content
elseif j.choices[1].message and j.choices[1].message.content then
piece = j.choices[1].message.content
end
end
if not piece and j.candidates and j.candidates[1] and j.candidates[1].content and j.candidates[1].content.parts then
local pList = {}
for _, part in ipairs(j.candidates[1].content.parts) do
local pt = extractGeminiPartText(part)
if #pt > 0 then table.insert(pList, pt) end
end
if #pList > 0 then piece = table.concat(pList, "") end
end
if piece then table.insert(chunks, tostring(piece)) end
else
table.insert(chunks, d)
end
end
end
if #chunks > 0 then
return trimText(table.concat(chunks, ""))
end
end
local ok, j = pcall(cjson.decode, trimmed)
if ok and type(j) == "table" then
if j.usage_get or j.available_models or (j.creator and j.status == "success" and not j.response and not j.result and not j.text) then
return ""
end
if j.candidates and j.candidates[1] and j.candidates[1].content and j.candidates[1].content.parts then
local gParts = {}
for _, part in ipairs(j.candidates[1].content.parts) do
local pt = extractGeminiPartText(part)
if #pt > 0 then
table.insert(gParts, pt)
end
end
if #gParts > 0 then
return trimText(table.concat(gParts, ""))
end
end
local res = j.result or j.response or j.text or j.content or j.reply or j.output
if not res and j.choices and j.choices[1] and j.choices[1].message then
res = j.choices[1].message.content
end
if res then
return trimText(res)
end
return ""
end
return trimmed
end
local function buildAIPrompt(inputText, isAudioMode)
local baseInstruction = DEFAULT_AI_INSTRUCTION
if getPref("ai_custom_inst_use", false) then
local customTxt = getPref("ai_custom_inst_text", "")
if #customTxt:gsub("%s+", "") > 0 then
baseInstruction = customTxt
end
end
local rules = {}
if isAudioMode then
local recLang = getPref("lang_recognizer_name", "")
if #recLang > 0 then
table.insert(rules, "Dengarkan rekaman audio ini dengan sangat cermat (bahasa utama pembicara: " .. recLang .. ") dan transkripsikan seluruh ucapan menjadi teks yang akurat.")
else
table.insert(rules, "Dengarkan rekaman audio ini dengan sangat cermat dan transkripsikan seluruh ucapan menjadi teks yang akurat.")
end
end
if getPref("fitur_auto_clean", false) then
table.insert(rules, "Bersihkan seluruh gangguan suara (noise), gumaman tidak bermakna, artefak transkripsi, pengulangan gagap yang tidak disengaja, dan halusinasi teks agar hasilnya bersih dan jelas.")
end
local style = getPref("ai_style", "Normal")
local styleMap = {
["Normal"] = "Gunakan gaya bahasa normal dan natural sesuai dengan apa yang diucapkan.",
["Profesional"] = "Ubah gaya bahasa teks menjadi profesional, korporat, sopan, dan kredibel tanpa menghilangkan makna inti.",
["Lucu"] = "Ubah gaya bahasa teks menjadi lucu, jenaka, dan menghibur tanpa menghilangkan inti pesannya.",
["Romantis"] = "Ubah gaya bahasa teks menjadi romantis, manis, puitis, dan menyentuh hati.",
["Kasual"] = "Ubah gaya bahasa teks menjadi kasual, santai, luwes, dan akrab seperti obrolan sehari-hari.",
["Formal"] = "Ubah gaya bahasa teks menjadi bahasa resmi, baku, dan sangat sopan sesuai EYD.",
["Singkat"] = "Ringkas teks menjadi singkat, padat, lugas, dan langsung ke inti pembicaraan.",
["Puitis"] = "Ubah gaya bahasa teks menjadi puitis dengan pilihan diksi sastra yang indah dan mengalir.",
["Tegas"] = "Ubah gaya bahasa teks menjadi tegas, lugas, berwibawa, dan penuh keyakinan.",
["Ramah"] = "Ubah gaya bahasa teks menjadi sangat ramah, hangat, sopan, dan bersahabat.",
["Akademis"] = "Ubah gaya bahasa teks menjadi akademis, ilmiah, objektif, dan terstruktur rapi.",
["Persuasif"] = "Ubah gaya bahasa teks menjadi persuasif, menarik, dan meyakinkan pembaca.",
["Storytelling"] = "Sampaikan teks dengan gaya bercerita (storytelling) yang hidup, mengalir, dan menarik.",
["Sarkastik"] = "Ubah gaya bahasa teks menjadi sarkastik, menyindir secara halus dan cerdas tanpa menghilangkan maksud utama.",
["Empatik"] = "Ubah gaya bahasa teks menjadi penuh empati, lembut, peduli, dan menenangkan.",
["Jurnalistik"] = "Ubah gaya bahasa teks menjadi gaya jurnalistik seperti berita profesional yang lugas, faktual, objektif, dan informatif.",
["Motivasi"] = "Ubah gaya bahasa teks menjadi penuh semangat, inspiratif, membangkitkan energi positif, dan memotivasi.",
["Diplomatis"] = "Ubah gaya bahasa teks menjadi diplomatis, halus, bijaksana, menjaga perasaan lawan bicara, dan menghindari konflik.",
["Bisnis"] = "Ubah gaya bahasa teks menjadi bahasa bisnis dan eksekutif yang strategis, ringkas, berorientasi hasil, dan profesional.",
["Edukatif"] = "Ubah gaya bahasa teks menjadi edukatif seperti penjelasan seorang pengajar yang runtut, jelas, dan mudah dipahami.",
["Kreatif"] = "Ubah gaya bahasa teks menjadi kreatif, segar, imajinatif, dan menarik perhatian seperti naskah iklan modern.",
["Poin-poin"] = "Susun ulang isi teks menjadi daftar poin-poin yang terstruktur rapi, jelas, dan mudah dibaca sekilas.",
["Dramatis"] = "Ubah gaya bahasa teks menjadi dramatis, ekspresif, penuh penekanan emosi, dan memikat.",
["Sopan Santun"] = "Ubah gaya bahasa teks menjadi sangat halus, penuh tata krama, hormat, dan menghargai lawan bicara.",
["Netral"] = "Ubah gaya bahasa teks menjadi sepenuhnya netral, tenang, berimbang, dan bebas dari bias emosional."
}
table.insert(rules, styleMap[style] or styleMap["Normal"])
local khususMode = getPref("khusus_mode", "normal")
if getPref("umum_emoji_mode", false) and khususMode == "normal" then
local lvl = getPref("umum_emoji_level", "Sedang")
if lvl == "Rendah" then
table.insert(rules, "Tambahkan sedikit emoji (1 sampai 2 emoji saja di bagian paling relevan). Langsung tampilkan hasil teks beserta emojinya tanpa komentar apa pun.")
elseif lvl == "Tinggi" then
table.insert(rules, "Tambahkan banyak emoji ekspresif yang bervariasi di setiap kalimat atau frasa yang cocok. Langsung tampilkan hasil teks beserta emojinya tanpa komentar apa pun.")
else
table.insert(rules, "Tambahkan emoji dengan tingkat sedang dan seimbang sesuai emosi kalimat. Langsung tampilkan hasil teks beserta emojinya tanpa komentar apa pun.")
end
else
table.insert(rules, "Jangan menambahkan emoji apa pun ke dalam teks.")
end
if getPref("umum_mixed", false) then
table.insert(rules, "Pertahankan istilah atau kata bahasa campuran yang diucapkan secara alami.")
end
if getPref("lang_translate_use", false) then
local targetLangName = getPref("lang_translate_target_name", "English")
table.insert(rules, "Terjemahkan seluruh hasil teks akhirnya ke dalam bahasa " .. targetLangName .. " secara akurat.")
end
table.insert(rules, "MUTLAK: Langsung kirimkan hasil akhirnya saja tanpa kata pembuka, tanpa penjelasan, tanpa komentar sedikit pun, dan tanpa tanda kutip.")
if isAudioMode then
return baseInstruction .. "\n\nInstruksi Pengaturan Aktif:\n- " .. table.concat(rules, "\n- ")
end
return baseInstruction .. "\n\nInstruksi Pengaturan Aktif:\n- " .. table.concat(rules, "\n- ") .. "\n\nTeks Input:\n" .. inputText
end
local function resolveGeminiModelId()
local selected = getPref("ai_gemini_model", "Gemini Flash")
return GEMINI_MODEL_ALIAS[selected] or selected
end
local function callGoogleGeminiDirect(promptText, onResult, audioBase64, audioMime)
local apiKey = trimText(getPref("ai_custom_api_key", ""))
if #apiKey == 0 then
onResult(false, "")
return
end
local primaryModelId = resolveGeminiModelId()
local modelQueue = { primaryModelId }
if primaryModelId ~= "gemini-2.5-flash" then
table.insert(modelQueue, "gemini-2.5-flash")
end
if primaryModelId ~= "gemini-2.0-flash" then
table.insert(modelQueue, "gemini-2.0-flash")
end
local partsList = {
{ text = promptText }
}
if audioBase64 and #audioBase64 > 0 then
table.insert(partsList, {
inlineData = {
mimeType = audioMime or "audio/mp4",
data = audioBase64
}
})
end
local payloadJson = cjson.encode({
contents = {
{
role = "user",
parts = partsList
}
}
})
local function tryGeminiModel(idx)
if idx > #modelQueue then
onResult(false, "")
return
end
local mId = modelQueue[idx]
local endpoint = GEMINI_API_BASE .. "/" .. urlencode(mId) .. ":generateContent?key=" .. urlencode(apiKey)
httpPostJson(endpoint, payloadJson, function(sc, body)
if sc == 200 and #body > 0 then
local parsed = parseAIResponse(body)
if #parsed > 0 then
onResult(true, parsed)
return
end
end
if sc == 404 then
tryGeminiModel(idx + 1)
else
onResult(false, "")
end
end)
end
tryGeminiModel(1)
end
local function fallbackGoogleTranslate(text, fallbackNode, skipNonstopLoop)
if getPref("lang_translate_use", false) then
local rawTarget = getPref("lang_translate_target", "id-ID")
local targetLang = string.gsub(rawTarget, "_", "-")
local gUrl = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=" .. targetLang .. "&dt=t&q=" .. urlencode(text)
Http.get(gUrl, function(gCode, gBody)
local gStatus = tonumber(tostring(gCode)) or 0
if gStatus == 200 and gBody then
local ok, json = pcall(cjson.decode, tostring(gBody))
if ok and json and json[1] then
local transText = ""
for i = 1, #json[1] do
transText = transText .. tostring(json[1][i][1])
end
insertResultFinal(transText, skipNonstopLoop, fallbackNode)
return
end
end
insertResultFinal(text, skipNonstopLoop, fallbackNode)
end)
else
insertResultFinal(text, skipNonstopLoop, fallbackNode)
end
end
local function processWithAIUltra(text, fallbackNode, skipNonstopLoop)
local prompt = buildAIPrompt(text, false)
if getPref("ai_custom_api_use", false) then
callGoogleGeminiDirect(prompt, function(okGem, gemResult)
if okGem and #gemResult > 0 then
insertResultFinal(gemResult, skipNonstopLoop, fallbackNode)
else
fallbackGoogleTranslate(text, fallbackNode, skipNonstopLoop)
end
end)
return
end
local model = getPref("ai_model", "gpt-sol")
local url = AI_BASE_URL .. "?chat=" .. urlencode(prompt) .. "&model=" .. urlencode(model)
local function onAIHttpFinished(code, body)
local statusCode = tonumber(tostring(code)) or 0
if statusCode == 200 and body then
local result = parseAIResponse(body)
if #result > 0 then
insertResultFinal(result, skipNonstopLoop, fallbackNode)
return
end
end
fallbackGoogleTranslate(text, fallbackNode, skipNonstopLoop)
end
if #url > 1800 then
local jsonPayload = cjson.encode({
chat = prompt,
model = model
})
httpPostJson(AI_BASE_URL, jsonPayload, function(sc, body)
local parsedPost = (sc == 200 and #body > 0) and parseAIResponse(body) or ""
if #parsedPost > 0 then
insertResultFinal(parsedPost, skipNonstopLoop, fallbackNode)
else
Http.get(url, onAIHttpFinished)
end
end)
else
Http.get(url, onAIHttpFinished)
end
end
local function processRecordedAudioWithAI(audioBase64, audioMime, fallbackNode)
local audioPrompt = buildAIPrompt("", true)
local savedGeminiKey = trimText(getPref("ai_custom_api_key", ""))
local function finishWithTranscribedText(rawTranscript)
local filtered = processTextLocal(rawTranscript, false)
if getPref("ai_custom_api_use", false) then
insertResultFinal(filtered, true, fallbackNode)
else
processWithAIUltra(filtered, fallbackNode, true)
end
end
if #savedGeminiKey > 0 then
local directPrompt = getPref("ai_custom_api_use", false)
and audioPrompt
or "Transkripsikan rekaman audio ini menjadi teks secara akurat sesuai bahasa yang diucapkan. Langsung kirimkan hasil transkripsi tanpa komentar apa pun."
callGoogleGeminiDirect(directPrompt, function(okGem, gemText)
if okGem and #gemText > 0 then
if getPref("ai_custom_api_use", false) then
local cleaned = processTextLocal(gemText, false)
insertResultFinal(cleaned, true, fallbackNode)
else
finishWithTranscribedText(gemText)
end
else
safeSpeak("Gagal mentranskripsi rekaman audio. Periksa kunci API atau koneksi internet Anda.")
if wakeLock and wakeLock.isHeld() then wakeLock.release() end
end
end, audioBase64, audioMime)
return
end
local hubModel = getPref("ai_model", "gemini-flash")
local hubPayload = cjson.encode({
chat = audioPrompt,
model = hubModel,
audio = audioBase64,
mime_type = audioMime
})
httpPostJson(AI_BASE_URL, hubPayload, function(sc, body)
local parsed = (sc == 200 and #body > 0) and parseAIResponse(body) or ""
if #parsed > 0 then
local cleaned = processTextLocal(parsed, false)
insertResultFinal(cleaned, true, fallbackNode)
else
safeSpeak("Gagal mentranskripsi rekaman audio. Silakan aktifkan Custom Kunci API Gemini di Pengaturan AI untuk mode rekaman suara.")
if wakeLock and wakeLock.isHeld() then wakeLock.release() end
end
end)
end
local function deleteTempAudioFile(filePath)
if filePath and #tostring(filePath) > 0 then
pcall(function()
local f = File(tostring(filePath))
if f.exists() then
f.delete()
end
end)
end
end
local function encodeAudioFileToBase64(filePath)
local b64Result = nil
pcall(function()
local f = File(tostring(filePath))
if not f.exists() or f.length() <= 0 then
return
end
local fis = FileInputStream(f)
local baos = ByteArrayOutputStream()
local buffer = luajava.newArray(Byte.TYPE, 4096)
local bytesRead = fis.read(buffer)
while bytesRead ~= -1 do
baos.write(buffer, 0, bytesRead)
bytesRead = fis.read(buffer)
end
fis.close()
local allBytes = baos.toByteArray()
baos.close()
b64Result = tostring(Base64.encodeToString(allBytes, Base64.NO_WRAP))
end)
return b64Result
end
local function cleanupContinuousRecorder()
local state = _G.ULTRA_REC_STATE
state.isRecording = false
setPref("is_recording_exp", false)
if state.recorder then
pcall(function() state.recorder.stop() end)
pcall(function() state.recorder.reset() end)
pcall(function() state.recorder.release() end)
state.recorder = nil
end
if state.audioPath then
deleteTempAudioFile(state.audioPath)
state.audioPath = nil
end
end
local function startContinuousVoiceSession()
cleanupContinuousRecorder()
if getPref("fitur_wakelock", false) then
if not wakeLock then
wakeLock = pm.newWakeLock(PowerManager.SCREEN_BRIGHT_WAKE_LOCK + PowerManager.ACQUIRE_CAUSES_WAKEUP, "Jieshuo:VoiceAIUltra")
end
if not wakeLock.isHeld() then wakeLock.acquire(30 * 60 * 1000) end
end
muteMediaIfEnabled()
if getPref("fitur_vibrate", true) then vibrator.vibrate(60) end
playBeep(true)
local cachePath = "/storage/emulated/0/.isau_temp_audio.m4a"
pcall(function()
local cDir = service.getCacheDir()
if cDir then
cachePath = tostring(cDir.getAbsolutePath()) .. "/isau_rec_" .. tostring(os.time()) .. ".m4a"
end
end)
deleteTempAudioFile(cachePath)
local mr = nil
local started = pcall(function()
mr = MediaRecorder()
local okSrc = pcall(function()
mr.setAudioSource(MediaRecorder.AudioSource.VOICE_RECOGNITION)
end)
if not okSrc then
mr.setAudioSource(MediaRecorder.AudioSource.MIC)
end
mr.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
mr.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
pcall(function() mr.setAudioSamplingRate(16000) end)
pcall(function() mr.setAudioChannels(1) end)
pcall(function() mr.setAudioEncodingBitRate(32000) end)
mr.setOutputFile(cachePath)
mr.prepare()
mr.start()
end)
if started and mr then
local state = _G.ULTRA_REC_STATE
state.isRecording = true
state.recorder = mr
state.audioPath = cachePath
state.targetNode = service.getEditText()
setPref("is_recording_exp", true)
else
if mr then
pcall(function() mr.release() end)
end
deleteTempAudioFile(cachePath)
restoreMediaVolume()
if wakeLock and wakeLock.isHeld() then wakeLock.release() end
safeSpeak("Gagal memulai perekaman mikrofon")
end
end
local function stopContinuousVoiceSession()
local state = _G.ULTRA_REC_STATE
state.isRecording = false
setPref("is_recording_exp", false)
if getPref("fitur_vibrate", true) then vibrator.vibrate(80) end
playBeep(false)
restoreMediaVolume()
local mr = state.recorder
local audioPath = state.audioPath
local savedNode = state.targetNode
state.recorder = nil
state.audioPath = nil
if mr then
pcall(function() mr.stop() end)
pcall(function() mr.reset() end)
pcall(function() mr.release() end)
end
if audioPath then
local base64Audio = encodeAudioFileToBase64(audioPath)
deleteTempAudioFile(audioPath)
if base64Audio and #base64Audio > 64 then
safeSpeak("Memproses rekaman")
processRecordedAudioWithAI(base64Audio, "audio/mp4", savedNode)
else
safeSpeak("Rekaman terlalu singkat atau tidak ada suara")
if wakeLock and wakeLock.isHeld() then wakeLock.release() end
end
else
safeSpeak("Rekaman tidak ditemukan")
if wakeLock and wakeLock.isHeld() then wakeLock.release() end
end
end
function startVoiceInput()
if getPref("fitur_wakelock", false) then
if not wakeLock then
wakeLock = pm.newWakeLock(PowerManager.SCREEN_BRIGHT_WAKE_LOCK + PowerManager.ACQUIRE_CAUSES_WAKEUP, "Jieshuo:VoiceAIUltra")
end
if not wakeLock.isHeld() then wakeLock.acquire(10 * 60 * 1000) end
end
muteMediaIfEnabled()
if getPref("fitur_vibrate", true) then vibrator.vibrate(50) end
local msgMode = "Mulai mendengarkan"
if getPref("umum_whisper", false) then msgMode = "Mode bisik bisik aktif" end
safeSpeak(msgMode)
local savedNode = service.getEditText()
local rec = SpeechRecognizer.createSpeechRecognizer(service)
local it = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
if getPref("umum_whisper", false) then
it.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_WEB_SEARCH)
else
it.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
end
it.putExtra(RecognizerIntent.EXTRA_LANGUAGE, getPref("lang_recognizer", "id-ID"))
rec.setRecognitionListener(luajava.createProxy("android.speech.RecognitionListener", {
onReadyForSpeech = function() end,
onBeginningOfSpeech = function() end,
onRmsChanged = function() end,
onBufferReceived = function() end,
onEndOfSpeech = function() end,
onError = function(err)
if getPref("fitur_comeback", false) and getPref("is_running_nonstop", true) then
mainHandler.postDelayed(Runnable({run = function() rec.destroy(); startVoiceInput() end}), 500)
else
if getPref("fitur_vibrate", true) then vibrator.vibrate(100) end
safeSpeak("Pendengaran gagal")
setPref("is_running_nonstop", false)
restoreMediaVolume()
if wakeLock and wakeLock.isHeld() then wakeLock.release() end
rec.destroy()
end
end,
onResults = function(res)
local raw = res.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
if raw and raw.size() > 0 then
local rawText = tostring(raw.get(0))
local localFilteredText = processTextLocal(rawText, false)
processWithAIUltra(localFilteredText, savedNode, false)
else
restoreMediaVolume()
end
rec.destroy()
end
}))
rec.startListening(it)
end
if service.getEditText() then
if getPref("audio_use_recorder", false) then
if _G.ULTRA_REC_STATE.isRecording or getPref("is_recording_exp", false) then
stopContinuousVoiceSession()
else
startContinuousVoiceSession()
end
else
if getPref("umum_nonstop", false) then
if getPref("is_running_nonstop", false) then
setPref("is_running_nonstop", false)
safeSpeak("Input dihentikan")
restoreMediaVolume()
if wakeLock and wakeLock.isHeld() then wakeLock.release() end
else
setPref("is_running_nonstop", true)
startVoiceInput()
end
else
setPref("is_running_nonstop", true)
startVoiceInput()
end
end
else
if _G.ULTRA_REC_STATE.isRecording or getPref("is_recording_exp", false) then
cleanupContinuousRecorder()
end
setPref("is_running_nonstop", false)
restoreMediaVolume()
if wakeLock and wakeLock.isHeld() then wakeLock.release() end
bukaPengaturanUtama()
end
return true
=IDQ8Xq1Uf5vBDEFNVpQSjqj2EFJBftY2rLUrMXYtACHPDKMBSuuGATqnhv0oQuJgMmyqSFd8qfEWCAzCGda8+Lpi8G+/mEONRfh4DQ0ayxBBqvePT1jnU6lYEBBGSO7gpKMHAPr6ytwQ1NICIgwaxbOQ9mEvX3Ybd+0U1Dt0z45ISY+AtIeyQcB+86P3LAtjAbueTyGimCMteGYmluNHBVrhH+5Rry7NlJrv52/5dvh5xBwSrfT0I5MOq0QH2zFH4lWuj+08n0D+FW7MSbXTfmxbn44dkNnrROTwp10+O7kp1Mn9Jf7MSHST8effh7y64feQi9+iPTS6beXX669cNYN5I7BlP4K5uDt1AwF42tVasdAzvgHwnU8EMfFAylrPGLewiHzEY4XgXAaEw7niHMo/HmHiPqDhH7pDhyRUCwkoyn6E823jZXiJgEcC2lfZtr64YP3qCgfFeWjomxElI2IshFRppc7JAVDrL9gzLOtRETJQmpLdGyJji3RsSW6heNxZ4oyFc5HiMJhcFcUR9Gsk1BOMdsQXULxDWxDogPO+pAsJZPuoinTVjSPbkx13H2JkoqTSM6yEwnjBUfPnkQJ+V4KegkRFWwEO32zThwGX/H8w1Y83DVkICKWvhjtiL6Nik8sDu3LRF4yD++I5ujedF2W2HfOVDLcokvGLgGJ9FC9SutAvWxgMzFhLIkGiXDUD5zEF0Xzav0ubJjScWBXSl5S+SQcDOl2K3VianRFAiMVAv1lY+ooK2gL6I1JNhIX6nL9DijQZUOol0zMMJNJP0dChrNUMUgQVQvhcAY+fPlYQt0V7auifVWiZCCzItpmoK8jymhFomTi7phjZO/rN+OYATwG4m3KyuNKooF6WUAVHELOULIDoDo4Sl4kfl12/o/Qf9JI9bbqRuNhX2Tsj9AqBnZsJIVuKqgH6HvuJnGKp71rMcjZBSmqLakJuqbRnWhtki7oX9cpoaK8F50tRSJBX/+bgyERq8fbtkWYxX72/nvgloMQcydi7iRKJo5BRZhnz770rYgPabwp3eMNonzq6v0GPhcV3I2Iu5HIc6RWyWaZqXnXnS4aO8CDLhl7b2fxUAFAy1JOQLok07t5WQQeS2xQ0R9kiud1StyNyRVEvUdAR+NCymmqtwxkE8gJHImAv/FfWHxJ0V0ZNR7plsQjN4fajPKx2C6JbXEq+u/jlEwcXqDvI5VbIrb4eqf4QyjHN6JMMVtdbyNQSNA+rYC943NtrQ2N57rs4SNmByLopE5MX6S3dUo/1Dg9Uth8JxXoucTm+93QbRKU6ydA
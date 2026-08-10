loadAPI(3);

host.defineController(
   "sillytina",
   "Collapse Visible Devices",
   "3.0.0",
   "d04f51bc-1b5f-4ce8-a7dc-52d5d5403acd",
   "SillyTina"
);
host.defineMidiPorts(0, 0);

var MAX_DEVICE_SLOTS = 256;
var COMMAND_BRIDGE_NAME = "SillyTina Collapse Visible Devices";
var COMMAND_BRIDGE_PORT = 47612;
var COMMAND_BRIDGE_TOKEN = "BITWIG_COLLAPSE_V1";

var cursorTrack = null;
var cursorTrackExists = null;
var cursorTrackName = null;
var trackedDevices = [];

function init()
{
   configureCommandBridge();

   cursorTrack = host.createCursorTrack(
      "sillytina-collapse-visible-devices-selected-track",
      "SillyTina Collapse Visible Devices Selected Track",
      0,
      0,
      true
   );
   cursorTrackExists = cursorTrack.exists();
   cursorTrackName = cursorTrack.name();
   cursorTrackExists.markInterested();
   cursorTrackName.markInterested();

   var deviceBank = cursorTrack.createDeviceBank(MAX_DEVICE_SLOTS);
   for (var index = 0; index < MAX_DEVICE_SLOTS; index++)
   {
      var device = deviceBank.getDevice(index);
      var exists = device.exists();
      var isExpanded = device.isExpanded();

      exists.markInterested();
      isExpanded.markInterested();

      trackedDevices[index] = {
         exists: exists,
         isExpanded: isExpanded
      };
   }
}

function configureCommandBridge()
{
   var didBind = host.addDatagramPacketObserver(
      COMMAND_BRIDGE_NAME,
      COMMAND_BRIDGE_PORT,
      onCommandDatagram
   );

   if (!didBind)
   {
      host.showPopupNotification(
         "Collapse Visible Devices: command port is already in use"
      );
   }
}

function onCommandDatagram(data)
{
   if (matchesAsciiToken(data, COMMAND_BRIDGE_TOKEN))
   {
      collapseSelectedTrackDevices();
   }
}

function matchesAsciiToken(data, expectedToken)
{
   if (data.length !== expectedToken.length)
   {
      return false;
   }

   for (var index = 0; index < expectedToken.length; index++)
   {
      if (data[index] !== expectedToken.charCodeAt(index))
      {
         return false;
      }
   }

   return true;
}

function collapseSelectedTrackDevices()
{
   if (!cursorTrackExists.get())
   {
      host.showPopupNotification("Collapse Visible Devices: no track selected");
      return;
   }

   var existingDeviceCount = 0;
   var expandedDeviceCount = 0;

   for (var index = 0; index < trackedDevices.length; index++)
   {
      var trackedDevice = trackedDevices[index];
      if (!trackedDevice.exists.get())
      {
         continue;
      }

      existingDeviceCount++;
      if (trackedDevice.isExpanded.get())
      {
         expandedDeviceCount++;
      }

      trackedDevice.isExpanded.set(false);
   }

   if (existingDeviceCount === 0)
   {
      host.showPopupNotification("Collapse Visible Devices: selected track has no devices");
      return;
   }

   if (expandedDeviceCount > 0)
   {
      host.showPopupNotification(
         "Collapsed " + expandedDeviceCount + " device" +
         (expandedDeviceCount === 1 ? "" : "s") +
         " on " + cursorTrackName.get()
      );
   }
}

function flush()
{
}

function exit()
{
}

# Changelog

## [Unreleased]

### Added

- New ModEvent DSE_DeviceEvent to notify when an actor is slotted or un-slotted. Usage:
  ```lua
  RegisterForModEvent("DSE_DeviceEvent","OnDSEFurniture")
  
  event OnDSEFurniture(Form actorRef, Form device, int slot, bool entering)
     ; do something useful 
  endevent
  ```

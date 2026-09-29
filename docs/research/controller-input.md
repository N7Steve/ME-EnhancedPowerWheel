# LE3 controller input

The installed LE3 `BioPlayerInput` defaults bind `XboxTypeS_RightThumbstick` to `GuiKey BIOGUI_EVENT_BUTTON_RTHUMB` and its release event, and `XboxTypeS_LeftThumbstick` to `GuiKey BIOGUI_EVENT_BUTTON_LTHUMB` and its release event. These are the exact button identifiers used in the POC; no global input binding is changed.

`SFXGUIInteraction.HandleInputEvent()` is native and accepts `BioGuiEvents`, controller ID, cooldown, value, and deadzone. `SFXSFHandler_PowerWheel.HandleInputEvent()` is script and receives `BioGuiEvents`; its vanilla switch handles left-stick axes and A/X/B/Y, forwarding unhandled events to `Super(SFXGUIMovie).HandleInputEvent()`. This supports a wheel-local interception point, but a binding alone does not prove delivery to the wheel. That dispatch still needs an in-game controller test.

The POC consumes L3/R3 only when the handler's mode is `PWM_Powers`; outside that mode it keeps the original superclass path. It also consumes A on empty page 1 through `SelectCurrentWheelItem()` and suppresses X/B/Y mapping there. Whether an upstream layer also acts on the thumb clicks must be tested.

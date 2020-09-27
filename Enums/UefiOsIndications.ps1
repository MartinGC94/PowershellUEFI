[Flags()] enum UefiOsIndications
{
    BootToFwUi                   = 1
    TimestampRevocation          = 2
    FileCapsuleDeliverySupported = 4
    FmpCapsuleSupported          = 8
    CapsuleResultVarSupported    = 16
    StartPlatformRecovery        = 64
}
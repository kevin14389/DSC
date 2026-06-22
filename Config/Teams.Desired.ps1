# =============================================================================
# CONFIGURATION SOUHAITEE (BASELINE TEAMS)
# =============================================================================
# Remplace les valeurs par ta configuration cible réelle.
# Ce fichier est la référence contre laquelle les exports seront comparés.
# =============================================================================

$DesiredConfig = @{

    # -------------------------------------------------------------------------
    # TeamsClientConfiguration
    # -------------------------------------------------------------------------
    TeamsClientConfiguration = @{
        AllowBox                         = $false
        AllowDropBox                     = $false
        AllowEgnyte                      = $false
        AllowEmailIntoChannel            = $true
        AllowGoogleDrive                 = $false
        AllowGuestUser                   = $true
        AllowOrganizationTab             = $true
        AllowShareFile                   = $false
        AllowSkypeBusinessInterop        = $true
        ContentPin                       = "RequiredOutsideScheduleMeeting"
        ResourceAccountContentAccess     = "NoAccess"
    }

    # -------------------------------------------------------------------------
    # TeamsMeetingPolicy (Global)
    # -------------------------------------------------------------------------
    TeamsMeetingPolicy = @{
        Identity                         = "Global"
        AllowAnonymousUsersToJoinMeeting = $false
        AllowCloudRecording              = $true
        AllowExternalParticipantGiveRequestControl = $false
        AllowMeetNow                     = $true
        AllowOutlookAddIn                = $true
        AllowParticipantGiveRequestControl = $true
        AllowPrivateMeetingScheduling    = $true
        AllowPSTNUsersToBypassLobby      = $false
        AllowRecordingStorageOutsideRegion = $false
        AllowTranscription               = $true
        AutoAdmittedUsers                = "EveryoneInCompany"
        ScreenSharingMode                = "EntireScreen"
        VideoFiltersMode                 = "AllFilters"
        WhoCanRegister                   = "EveryoneInCompany"
    }

    # -------------------------------------------------------------------------
    # TeamsMessagingPolicy (Global)
    # -------------------------------------------------------------------------
    TeamsMessagingPolicy = @{
        Identity                         = "Global"
        AllowGiphy                       = $true
        AllowMemes                       = $true
        AllowOwnerDeleteMessage          = $true
        AllowPriorityMessages            = $true
        AllowStickers                    = $true
        AllowUserChat                    = $true
        AllowUserDeleteMessage           = $true
        AllowUserEditMessage             = $true
        GiphyRatingType                  = "Moderate"
        ReadReceiptsEnabledType          = "UserPreference"
    }

    # -------------------------------------------------------------------------
    # TeamsCallingPolicy (Global)
    # -------------------------------------------------------------------------
    TeamsCallingPolicy = @{
        Identity                         = "Global"
        AllowCallForwardingToPhone       = $true
        AllowCallForwardingToUser        = $true
        AllowCallGroups                  = $true
        AllowCloudRecordingForCalls      = $false
        AllowDelegation                  = $true
        AllowPrivateCalling              = $true
        AllowVoicemail                   = "UserOverride"
        AllowWebPSTNCalling              = $true
        BusyOnBusyEnabledType            = "Disabled"
        PreventTollBypass                = $false
    }

    # -------------------------------------------------------------------------
    # TeamsChannelsPolicy (Global)
    # -------------------------------------------------------------------------
    TeamsChannelsPolicy = @{
        Identity                         = "Global"
        AllowChannelSharingToExternalUser = $false
        AllowOrgWideTeamCreation         = $false
        AllowPrivateChannelCreation      = $true
        AllowSharedChannelCreation       = $false
        AllowUserToParticipateInExternalSharedChannel = $false
        EnablePrivateTeamDiscovery       = $false
    }

    # -------------------------------------------------------------------------
    # TeamsFeedbackPolicy (Global)
    # -------------------------------------------------------------------------
    TeamsFeedbackPolicy = @{
        Identity                         = "Global"
        AllowEmailCollection             = $false
        AllowLogCollection               = $false
        AllowScreenshotCollection        = $false
        EnableFeatureSuggestions         = $false
        ReceiveSurveysMode               = "EnabledUserOverride"
        UserInitiatedMode                = "Enabled"
    }
}

return $DesiredConfig

{-# LANGUAGE FlexibleContexts #-}

import XMonad
import System.Environment (getEnvironment)
import XMonad.Config.Mate
import qualified Data.Map as M
import qualified XMonad.StackSet as W
import XMonad.Layout.Renamed
import XMonad.Actions.Navigation2D
import XMonad.Actions.RotSlaves
import XMonad.Actions.GroupNavigation
import XMonad.Layout.PerWorkspace
import XMonad.Layout.LayoutModifier
import XMonad.Layout.TwoPane
import XMonad.Layout.Spacing
import XMonad.Layout.Grid
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.ComboP
import XMonad.Layout.ThreeColumns
import XMonad.Util.Run
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import System.IO
import XMonad.Layout.ResizableTile
import XMonad.Layout.SubLayouts
import XMonad.Layout.Tabbed
import XMonad.Layout.WindowNavigation
import XMonad.Layout.Simplest
import XMonad.Actions.CycleWS
import XMonad.Actions.GridSelect
import XMonad.Actions.WindowBringer
import XMonad.Prompt.Window
import XMonad.Hooks.EwmhDesktops (ewmh)
import XMonad.Layout.Fullscreen
import XMonad.Util.NamedScratchpad


--main = do
--  xmproc <- spawnPipe "~/.local/bin/xmobar ~/xmobar.config"
--  xmonad =<< statusBar "xmobar ~/xmobar.config" myPP toggleStrutsKey (withNavigation2DConfig def {defaultTiledNavigation = hybridNavigation} $ myConfig)
--
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

myPP = namedScratchpadFilterOutWorkspacePP
     $ xmobarPP { ppOrder = \(ws:l:t:_) -> [ws]
                , ppCurrent = xmobarColor "yellow" "green" . wrap "" ""
		, ppTitle = xmobarColor "green" "" . shorten 30}
main = do
  xmonad myConfig 

myConfig = withNavigation2DConfig def {defaultTiledNavigation = hybridNavigation} $ mateConfig
  { terminal = "terminator"
  , modMask = mod4Mask
  , keys = myKeys <+> keys def
 -- , layoutHook = avoidStruts $ toggleLayouts Full $  myLayouts
  , layoutHook = desktopLayoutModifiers $ toggleLayouts Full $ myLayouts
  -- , logHook = dynamicLogWithPP $ xmobarPP { ppOutput = hPutStrLn p }
  --, handleEventHook = handleEventHook mateConfig <+> docksEventHook <+> fullscreenEventHook
  , handleEventHook = handleEventHook mateConfig 
  , logHook = historyHook <+> logHook mateConfig
  , borderWidth = 3
  , focusedBorderColor = solBlue
  , normalBorderColor = darkBlue
--  , manageHook = fullscreenManageHook <+> manageDocks <+> myManageHook <+> manageHook mateConfig
  , manageHook = myManageHook <+> manageHook mateConfig
  , XMonad.workspaces = myWorkspaces
  }

mateRegister' :: MonadIO m => m ()
mateRegister' = io $ do
  x <- lookup "DESKTOP_AUTOSTART_ID" `fmap` getEnvironment
  whenJust x $ \sessionId -> safeSpawn "dbus-send"
               ["--session"
               ,"--print-reply"
               ,"--dest=org.mate.SessionManager"
               ,"/org/mate/SessionManager"
               ,"org.mate.SessionManager.RegisterClient"
               ,"string:xmonad"
               ,"string:"++sessionId]

myWorkspaces = [ "conf", "term", "docs", "matlab", "media", "prog1", "prog2", "misc", "web" ]
-- layouts
-- SUBLAYOUT IS THE CAUSE OF FLOAT FOCUS LOST!!!
myLayouts =
  onWorkspace "conf" confLayout
  $ onWorkspace "term" terminalLayout
  $ onWorkspace "docs" readingLayout
  $ onWorkspace "web" webLayout
  $ onWorkspace "prog1" confLayout
  $ confLayout

mySpacing = spacingWithEdge 5
mySpacing' = smartSpacingWithEdge 7

confLayout =
  configurableNavigation noNavigateBorders $
  mySpacing $
  subLayout [] (Full) $
  simpleTall 53 ||| simpleThree 46 ||| (Mirror $ simpleTall 53)

readingLayout =
  configurableNavigation noNavigateBorders $
  mySpacing $
  simpleTwo 50 ||| (Mirror $ simpleTall 56)

terminalLayout =
  configurableNavigation noNavigateBorders $
  mySpacing $
  simpleTall 50 |||
  simpleThree 33 |||
  (Mirror $ simpleTall 53)

webLayout =
  configurableNavigation noNavigateBorders $
  mySpacing $ 
  Full |||
  simpleTwo 50

codingLayout =
  configurableNavigation noNavigateBorders $
  mySpacing $
  twoPaneTabbed |||
  simpleTall 50 |||
  (Mirror $ simpleTall 53)

twoPaneTabbed =
  combineTwoP (TwoPane 0.03 0.5) (tabbed shrinkText def) (tabbed shrinkText def) (ClassName "Firefox")
            

simpleTall n = ResizableTall 1 (3/100) (n/100) []

simpleThree :: Rational -> ThreeCol a
simpleThree n = ThreeCol 1 (3/100) (n/100)

simpleTwo :: Rational -> TwoPane a
simpleTwo n = TwoPane (3/100) (n/100)



-- named colors
solBlue = "#268bd2"
darkBlue = "#073642"

--manage hooks
myManageHook = composeOne
               [ name =? "Terminator Preferences" -?> insertPosition Above Newer <+> doCenterFloat
               , isDialog -?> insertPosition Above Newer <+> doCenterFloat
               , className =? "Eog" -?> insertPosition Below Older
               , className =? "MATLAB R2017b - academic use" -?> insertPosition Below Older
               , className =? "matplotlib" -?> insertPosition Below Older
	       , className =? "terminator" -?> insertPosition Below Newer
               --, name =? "DeSmuME" -?> insertPosition Above Newer <+> doCenterFloat
               , return True -?> insertPosition Below Newer]

  where name = stringProperty "WM_NAME"

-- Alt-Tab function
sameWorkSpace = do
  nw <- ask
  liftX $ do
    ws <- gets windowset
    return $ maybe False (== W.currentTag ws) (W.findTag nw ws)

altMask = mod1Mask
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList
        -- basic navigation
	[ ((altMask, xK_l), windowGo R False)
 	, ((altMask, xK_j), windowGo D False)
 	, ((altMask, xK_k), windowGo U False)
 	, ((altMask, xK_h), windowGo L False)
        , ((modm, xK_u), goToSelected def)
        , ((altMask, xK_Tab), nextMatch History sameWorkSpace)
        --, ((modm, xK_o), windowPrompt def Goto wsWindows)

        -- launching apps
        , ((modm, xK_g), spawn "emacsclient -c")
        , ((modm, xK_o), spawn "gnome-calculator")
        , ((modm, xK_apostrophe), spawn "qpdfview")
        , ((modm .|. altMask, xK_l), spawn "slock")
        , ((modm .|. altMask, xK_k), spawn "xscreensaver-command -activate")
	, ((modm .|. altMask, xK_h), spawn "terminator -e htop")
        , ((modm .|. altMask, xK_m), spawn "terminator -e cmus")
        , ((modm .|. altMask, xK_semicolon), spawn "firefox")
        , ((modm .|. altMask, xK_p), spawn "pavucontrol")
        , ((modm, xK_d), spawn "dmenu_run")

        -- resizing tall
        , ((modm, xK_a), sendMessage MirrorShrink)
        , ((modm, xK_z), sendMessage MirrorExpand)

        -- swapping windows
        , ((modm .|. shiftMask, xK_h), windowSwap L False)
        , ((modm .|. shiftMask, xK_l), windowSwap R False)
        , ((modm .|. shiftMask, xK_k), windows W.swapUp)
        , ((modm .|. shiftMask, xK_j), windows W.swapDown)

        -- combo layout
        , ((modm .|. shiftMask, xK_Right), sendMessage $ Move R)
        , ((modm .|. shiftMask, xK_Left), sendMessage $ Move L)
        , ((modm .|. shiftMask, xK_Up), sendMessage $ Move U)
        , ((modm .|. shiftMask, xK_Down), sendMessage $ Move D)
        , ((modm .|. shiftMask, xK_s), sendMessage $ SwapWindow)

        -- pulling windows into sublayouts
        , ((modm .|. controlMask, xK_h), sendMessage $ pullGroup L)
        , ((modm .|. controlMask, xK_l), sendMessage $ pullGroup R)
        , ((modm .|. controlMask, xK_k), sendMessage $ pullGroup U)
        , ((modm .|. controlMask, xK_j), sendMessage $ pullGroup D)
        , ((modm .|. controlMask, xK_m), withFocused (sendMessage . MergeAll))
        , ((modm .|. controlMask, xK_u), withFocused (sendMessage . UnMerge))

        --easy switching of workspaces
        , ((modm, xK_Left), prevWS)
        , ((modm, xK_Right), nextWS)

        --, ((altMask, xK_Tab), cycleRecentWS [xK_Alt_L] xK_Tab xK_grave)
        , ((modm, xK_Tab), toggleWS' ["NSP"])

        , ((modm, xK_grave), sendMessage $ ToggleLayout)

       -- rotate windows
        , ((altMask .|. shiftMask, xK_k), rotSlavesUp)
        , ((altMask .|. shiftMask, xK_j), rotSlavesDown)
        ]

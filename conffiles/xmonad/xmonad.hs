-- vim: nolist
import XMonad
import qualified Data.Map as M
import qualified XMonad.Layout.LayoutHints as LayoutHints
import XMonad.Hooks.EwmhDesktops hiding (fullscreenEventHook)
import XMonad.Layout.Reflect
import XMonad.Layout.LayoutScreens
import XMonad.Layout.SimpleFloat
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.UrgencyHook
import XMonad.Util.WindowProperties (getProp32)
import XMonad.Layout.Tabbed hiding (fontName)
import qualified XMonad.Layout.Named
import Data.IORef
import qualified XMonad.StackSet as W
import System.IO.Unsafe (unsafePerformIO)
import Data.List (isPrefixOf,intercalate)
import Graphics.X11.ExtraTypes.XF86
import XMonad.Hooks.ManageHelpers
import Foreign.C (CChar)
import XMonad.Layout.PerWorkspace
import Data.Char ( isSpace, ord)
import Data.Monoid
import Data.Maybe
import XMonad.Hooks.SetWMName
import XMonad.Layout.Fullscreen

data Amixer = SSet String String

spawnS = spawn . flip (++) " >/dev/null 2>&1"

shellQuote foo = "'" ++ concatMap quote1 foo ++ "\'"
	where quote1 '\'' = "'\\''"
	      quote1  x   = [x]

instance Show Amixer where
	show (SSet control param) = intercalate " " $ map shellQuote ["sset",control,param]

layouts = fullscreenFull $
          LayoutHints.layoutHints $
          avoidStruts $
          --onWorkspace "9" (Mirror $ Tall 1 (1/75) (4/5)) $
          ((Mirror tiled `named` "Horiz")
           ||| (tiled `named` "Vert")
           ||| simpleTabbed
           ||| simpleFloat)
  where tiled = reflectHoriz $ Tall nmaster delta ratio
        nmaster = 2
	ratio = 3/4
	delta = 3/100
        -- threecol = dragPaneSp Horizontal 0.2 0.5 2

named = flip XMonad.Layout.Named.named -- This way it can be used as an operator, and look normal

fontName :: String
fontName = "genera-jess14"

dmenu_cmd :: String
dmenu_cmd = "exe=`dmenu_path | dmenu -fn "
	    ++ fontName
	    ++ "` && eval \"exec $exe\""

shescape :: String -> String
shescape [] = []
shescape ('\'':a) = '\'':'\\':'\'':'\'':shescape a
shescape (a0:a) = a0:shescape a


-- | Write a string to a property on the root window.  This property is of
-- type UTF8_STRING. The string must have been processed by encodeString
-- (dynamicLogString does this).
xmonadPropLog' :: String -> String -> X ()
xmonadPropLog' prop msg = do
    d <- asks display
    r <- asks theRoot
    xlog <- getAtom prop
    ustring <- getAtom "UTF8_STRING"
    io $ changeProperty8 d r xlog ustring propModeReplace (encodeCChar msg)
 where
    encodeCChar :: String -> [CChar]
    encodeCChar = map (fromIntegral . ord)

-- | Write a string to the _XMONAD_LOG property on the root window.
--xmonadPropLog :: String -> X ()
--xmonadPropLog = xmonadPropLog' "_XMONAD_LOG"


myLogHook :: X ()
myLogHook = do dynamicLogString logPP >>= xmonadPropLog
               return ()
    where logPP = xmobarPP{ppCurrent=xmobarColor "green" ""
                          ,ppVisible=xmobarColor "#c0ffc0" ""
                          ,ppHidden=xmobarColor "CornflowerBlue" ""
                          ,ppHiddenNoWindows=xmobarColor "gray40" ""
                          ,ppUrgent=xmobarColor "red" "" . xmobarStrip
                          ,ppTitle=xmobarColor "green" "" . shorten 140
                          }
          shorten :: Int -> String -> String
          shorten n xs | length xs < n = xs
                       | otherwise     = (take (n - length end) xs) ++ end
              where
                end = "..."

          xmobarColor :: String  -- ^ foreground color: a color name, or #rrggbb format
                      -> String  -- ^ background color
                      -> String  -- ^ output string
                      -> String
          xmobarColor fg bg = wrap t "</fc>"
              where t = concat ["<fc=", fg, if null bg then "" else "," ++ bg, ">"]

          -- ??? add an xmobarEscape function?

          -- | Strip xmobar markup. Useful to remove ppHidden color from ppUrgent
          --   field. For example:
          --
          -- >     , ppHidden          = xmobarColor "gray20" "" . wrap "<" ">"
          -- >     , ppUrgent          = xmobarColor "dark orange" "" .  xmobarStrip
          xmobarStrip :: String -> String
          xmobarStrip = strip [] where
              strip keep x
                  | null x                 = keep
                  | "<fc="  `isPrefixOf` x = strip keep (drop 1 . dropWhile (/= '>') $ x)
                  | "</fc>" `isPrefixOf` x = strip keep (drop 5  x)
                  | '<' == head x          = strip (keep ++ "<") (tail x)
                  | otherwise              = let (good,x') = span (/= '<') x
                                             in strip (keep ++ good) x'
          -- | Wrap a string in delimiters, unless it is empty.
          wrap :: String  -- ^ left delimiter
               -> String  -- ^ right delimiter
               -> String  -- ^ output string
               -> String
          wrap _ _ "" = ""
          wrap l r m  = l ++ m ++ r

toggle :: IORef Bool -> X a -> X a -> X a
toggle ref ifTrue ifFalse =
    do val <- io $atomicModifyIORef ref (\x -> (not x,x))
       if val then ifTrue else ifFalse

screenMode :: IORef Bool
screenMode = unsafePerformIO $ newIORef True

amixer :: Amixer -> X ()
amixer cmd = spawnS $ "amixer " ++ show cmd

mykeys (XConfig {modMask = modm}) = M.fromList $
   [ ((modm, xK_p), spawn dmenu_cmd) -- %! Launch dmenu
   , ((mod4Mask, xK_F2), spawn "xscreensaver-command -lock") -- %! Start screensaver
   , ((modm .|. controlMask, xK_space), toggle screenMode rescreen (layoutScreens 2 (Mirror $ Tall 0 0 (1/2))))
   --, ((modm .|. shiftMask .|. controlMask , xK_space), rescreen)
   , ((modm, xK_b), sendMessage ToggleStruts)
   , ((modm, xK_0), windows $ W.greedyView "IM")
   , ((modm .|. shiftMask, xK_0), windows $ W.shift "IM")
   -- Audio
   , ((0, xF86XK_AudioLowerVolume), amixer (SSet mixer "1-"))
   , ((0, xF86XK_AudioRaiseVolume), amixer (SSet mixer "1+"))
   , ((0, xF86XK_AudioMute),        amixer (SSet mixer "toggle"))
   -- MPC
   , ((0, xF86XK_AudioPrev),	    spawnS "mpc prev")
   , ((0, xF86XK_AudioPlay),	    spawnS "mpc toggle")
   , ((0, xF86XK_AudioNext),	    spawnS "mpc next")
   ]
	where mixer = "Master,0"

-- border controls...

iGap (dt,db,dl,dr) (t,b,l,r) = (t+dt,b+db,l+dl,r+dr)

addGap desk part start =
    if desk == 0
    then (iGap part $ head start) : tail start
    else (head start) : addGap (desk - 1) part (tail start)

mkGaps = map $ foldl (flip iGap) (0,0,0,0)

myManageHook = composeOne $
	[ isFullscreen -?> doFullFloat
	]

withEventHook :: (Event -> X All) -> XConfig a -> XConfig a
withEventHook hook config = config{handleEventHook=handleEventHook config `mappend` hook}
withStartupHook :: (X ()) -> XConfig a -> XConfig a
withStartupHook hook config = config{startupHook=startupHook config `mappend` hook}
withManageHook hook config = config{manageHook=manageHook config `mappend` hook}

addFullscreen :: XConfig a -> XConfig a
addFullscreen = withEventHook fullscreenEventHook .
                withManageHook fullscreenManageHook .
                withStartupHook fsStartupHook
	where fsStartupHook = withDisplay $ \dpy -> do
		fullsc <- getAtom "_NET_WM_STATE_FULLSCREEN"
		supp <- getAtom "_NET_SUPPORTED"
		aAtom <- getAtom "ATOM"
		r <- asks theRoot
		oldSupp <- fromMaybe [] `fmap` getProp32 supp r
		io $ changeProperty32 dpy r supp aAtom propModeReplace (fromIntegral fullsc : oldSupp)


gaps = mkGaps $
  [ [ (16,0,0,0)	-- dzen
    , (0,3,0,0)		-- xbattbar
   -- , (0,0,0,24) 	-- pager
    ] ]

withWorkspaces :: [String] -> XConfig a -> XConfig a
withWorkspaces ws conf@(XConfig{keys=baseKeys}) =
    conf{workspaces = ws,
         keys = wsKeys `mappend` baseKeys}
        where keySet baseMod = [(baseMod .|. mod,key) | mod <- [0,controlMask,mod1Mask, controlMask .|. mod1Mask]
                                                      , key <- ([xK_1 .. xK_9] ++ [xK_0])]
              wsKeys (XConfig{modMask=modm}) =
                  M.fromList [(key, windows $ f i)
                                  | (submod,f) <- [(shiftMask,W.shift)
                                                  ,(0, W.greedyView)]
                             , (key,i) <- zip (keySet $ submod .|. modm) ws]

main = xmonad . withUrgencyHook NoUrgencyHook
	      . withStartupHook (setWMName "LG3D")
              . addFullscreen
              . ewmh
              $ defaultConfig
    { borderWidth        = 2
    , terminal           = "urxvt"
    , modMask		 = mod4Mask
    , workspaces         = [ "E" ] ++ [ show a | a <- [2..9]] ++ ["IM"]
    -- , workspaces         = words "A B C" ++ [ "d" ++ show x | x <- [4..10] ]
    --                       t b l r
    -- , defaultGaps        = gaps -- [(16,3,0,0)]
    , keys		 = mykeys `mappend` keys defaultConfig
    , manageHook = myManageHook
    , layoutHook = layouts
    , logHook		 = myLogHook
    , focusedBorderColor = "green"
    --, manageHook         = manageDocks
    }

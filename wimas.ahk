#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetKeyDelay, 1000  ; need this setting to avoid sending multiple keystrokes
#UseHook

#SingleInstance force

; monitor configurations
Desktop_Monitors := [{width: 1920, height: 1200}, {width: 1920, height: 1200}]

; function to return which monitor for given point
whichMonitor(monitors, point)
{
	x := point.x
	y := point.y
	beginX := 0
	beginY := 0
	endX := 0
	endY := 0
	mIdx := -1
	for index, monitor in monitors
	{
		if (index > 1) {
			beginX += monitors[index - 1].width
			beginY += monitors[index - 1].height
		}
		
		endX += monitor.width
		endY += monitor.height
		
		if ((x >= beginX) and (x < endX)) {
			mIdx := index
			break
		}
	}
	return mIdx
}

; function to return which monitor active windows belongs
whichMonitorForWinID(monitors, wID)
{
	WinGetPos, w_X, w_Y, , , ahk_id %wID%
	wm := whichMonitor(monitors, {x: w_X + 10, y: w_Y + 10})
	return {monitor: wm, x: w_X, y: w_Y}
}

; move window to given monitor index
moveWindow(monitors, wID, mIdx)
{
	; do nothing if move window to same monitor it stays
	if (mIdx == wm or mIdx <= 0 or mIdx > monitors.Length()) {
		return
	}

	wm := whichMonitorForWinID(monitors, wID)
	OutputDebug, %wm%
	
	step := -1
	index := wm.monitor - 1
	endIdx := mIdx
	if (mIdx > wm.monitor) {
		step := 1
		index := wm.monitor
		endIdx := mIdx - 1
	}

	while true
	{
		; only needs to caculate its x value
		wm.x += step * monitors[index].width
		
		if (index == endIdx) {
			break
		}
		
		index += step
	}
	
	WinMove, ahk_id %wID%, , wm.x, wm.y
}

; move windows to next monitor
moveWindow2Next(monitors, wID)
{
	wm := whichMonitorForWinID(monitors, wID)
	
	mIdx := wm.monitor + 1
	if (mIdx > monitors.Length()) {
		mIdx := 1
	}
	
	moveWindow(monitors, wID, mIdx)
}

; move windows to previous monitor
moveWindow2Previous(monitors, wID)
{
	wm := whichMonitorForWinID(monitors, wID)
	
	mIdx := wm.monitor - 1
	if (mIdx < 1) {
		mIdx := monitors.Length()
	}
	
	moveWindow(monitors, wID, mIdx)
}

; define hotkey to move window to next monitor
^#n::
	WinGet, active_ID, ID, A
	moveWindow2Next(Desktop_Monitors, active_ID)
Return

; define hotkey to move window to previous monitor
^#p::
	WinGet, active_ID, ID, A
	moveWindow2Previous(Desktop_Monitors, active_ID)
Return

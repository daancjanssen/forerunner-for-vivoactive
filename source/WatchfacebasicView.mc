using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time.Gregorian as Date;
using Toybox.Application as App;

class WatchfacebasicView extends WatchUi.WatchFace {

	var iconFont;
	var bigFont;
	var smallFont; 
	var screenWidth;
	var screenHeight;
	var fontHeight = 104;
	var screenCenterPoint;
	var clockDrawingCenterPoint;
	var batteryWidth = 40;
    var batteryHeight = 16;
    var batteryOffset = 10;
    var borderRadius = 3;
    var iconWidth = 10;
    var iconOffset = 30;
    var secondsWidth = 22;
    var secondsHeight = 18;
    var leadingZero;
	
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {  	
    	setLayout(Rez.Layouts.WatchFace(dc));
        iconFont = WatchUi.loadResource(Rez.Fonts.IconFont); 
       	bigFont = WatchUi.loadResource(Rez.Fonts.LargeFontBold); 
       	smallFont = WatchUi.loadResource(Rez.Fonts.LargeFontLight); 
       	screenWidth = dc.getWidth();
        screenHeight = dc.getHeight();
        screenCenterPoint = [screenWidth/2, screenHeight/2];
        clockDrawingCenterPoint = (screenHeight/2) - (fontHeight/2);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
    	dc.clearClip();
    	dc.setAntiAlias(true);
    	
    	//check for settings
    	leadingZero = App.getApp().getProperty("leadingZero");
    	
        // Get and show the current time
        var clockTime = System.getClockTime();
        dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
        
		setDateLabel();
		setClockLabelHours(clockTime);
        setClockLabelMinutes(clockTime);
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
		
		//do drawing outside of layout xml
        drawIcons(dc);
        setClockLabelSeconds(clockTime, dc);    
    }
    
    function onPartialUpdate(dc) {
    	dc.setClip(screenWidth-(secondsWidth/2)-secondsWidth, screenCenterPoint[1]-(secondsHeight/2), secondsWidth, secondsHeight);
    	dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_BLACK);
    	dc.clear();
    	dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
    	var clockTime = System.getClockTime();
    	setClockLabelSeconds(clockTime, dc);
    }
    
    function onSettingsChanged() { // triggered by settings change in GCM
	    WatchUi.requestUpdate();   // update the view to reflect changes
	}
    
    private function setClockLabelHours(clockTime) {
        var timeString = leadingZero && clockTime.hour < 10 ? Lang.format("0$1$", [clockTime.hour]) : Lang.format("$1$", [clockTime.hour]);
        var view = View.findDrawableById("ClockLabelHours");
        view.setText(timeString);
    }
    
    private function setClockLabelMinutes(clockTime) {
        var timeString = Lang.format("$1$", [clockTime.min.format("%02d")]);
        var view = View.findDrawableById("ClockLabelMinutes");
        view.setText(timeString);
    }
    
    private function setClockLabelSeconds(clockTime, dc) {
        var timeString = Lang.format("$1$", [clockTime.sec.format("%02d")]);
		dc.drawText(screenWidth-(secondsWidth/2), screenCenterPoint[1]-(secondsHeight/2)-4, Graphics.FONT_TINY, timeString, Graphics.TEXT_JUSTIFY_RIGHT);
    }
    
    private function setDateLabel() {        
    	var now = Time.now();
		var date = Date.info(now, Time.FORMAT_LONG);
		var dateString = Lang.format("$1$ $2$", [date.day_of_week, date.day]);
		var view = View.findDrawableById("DateLabel");
        view.setText(dateString);
    }
    
    private function drawIcons(dc) {
    	//battery
    	var battery = System.getSystemStats().battery.toFloat();	
    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    	dc.drawRoundedRectangle( screenCenterPoint[0]-(batteryWidth/2), batteryOffset, batteryWidth, batteryHeight, borderRadius);
    	//kapje
    	dc.drawRectangle( screenCenterPoint[0]+(batteryWidth/2)+1, batteryOffset+(batteryHeight/4), 2, (batteryHeight/2) );
    	    	
    	var bar = (100.0 / (batteryWidth - 4) ).toFloat();    	
    	var barLength = battery / bar;
    	    			
  		if (battery > 40) {
  			dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
  		}
    	else if (20 < battery <= 40) {
    		dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
    	}
    	else if (10 <= battery <= 20) {
    		dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
    	}
    	else if (battery < 10) {
    		dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
    	}
    	
    	dc.fillRoundedRectangle( screenCenterPoint[0]-(batteryWidth/2) + 2, batteryOffset + 2, barLength, batteryHeight-4, borderRadius-1);
    	
    	//alarm (symbol 1)
    	//bluetooth (symbol 0)
    	//dnd (symbol 2)
    	var deviceSettings = System.getDeviceSettings();
    	var BTConnected = deviceSettings.phoneConnected;
    	var alarmCount = deviceSettings.alarmCount;
    	var doNotDisturb = deviceSettings.doNotDisturb;
    	
    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		//1 icon
		if (!BTConnected && alarmCount > 0 && !doNotDisturb) {
	    	dc.drawText(screenCenterPoint[0], iconOffset, iconFont, "1", Graphics.TEXT_JUSTIFY_CENTER);
	    }
    	if (BTConnected && alarmCount == 0 && !doNotDisturb) {	
	    	dc.drawText(screenCenterPoint[0], iconOffset, iconFont, "0", Graphics.TEXT_JUSTIFY_CENTER);
	    }
	    if (!BTConnected && alarmCount == 0 && doNotDisturb) {
	    	dc.drawText(screenCenterPoint[0], iconOffset, iconFont, "2", Graphics.TEXT_JUSTIFY_CENTER);
	    }
	    //2 icons
	    if (BTConnected && alarmCount > 0 && !doNotDisturb) {
	    	dc.drawText(screenCenterPoint[0], iconOffset, iconFont, "1", Graphics.TEXT_JUSTIFY_LEFT);
	    	dc.drawText(screenCenterPoint[0], iconOffset, iconFont, "0", Graphics.TEXT_JUSTIFY_RIGHT);
	    }
	    if (!BTConnected && alarmCount > 0 && doNotDisturb) {
	    	dc.drawText(screenCenterPoint[0], iconOffset, iconFont, "1", Graphics.TEXT_JUSTIFY_RIGHT);
	    	dc.drawText(screenCenterPoint[0], iconOffset, iconFont, "2", Graphics.TEXT_JUSTIFY_LEFT);
	    }
	    if (BTConnected && alarmCount == 0 && doNotDisturb) {
	    	dc.drawText(screenCenterPoint[0], iconOffset, iconFont, "0", Graphics.TEXT_JUSTIFY_RIGHT);
	    	dc.drawText(screenCenterPoint[0], iconOffset, iconFont, "2", Graphics.TEXT_JUSTIFY_LEFT);
	    }
	    //3 icons
	    if (BTConnected && alarmCount > 0 && doNotDisturb) {
	    	dc.drawText(screenCenterPoint[0]-iconWidth, iconOffset, iconFont, "0", Graphics.TEXT_JUSTIFY_RIGHT);
	    	dc.drawText(screenCenterPoint[0], iconOffset, iconFont, "1", Graphics.TEXT_JUSTIFY_CENTER);
	    	dc.drawText(screenCenterPoint[0]+iconWidth, iconOffset, iconFont, "2", Graphics.TEXT_JUSTIFY_LEFT);
	    }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
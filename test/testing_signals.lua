#!/usr/bin/lua

require'qtcore'
require'qtgui'

local LCD_Range = function(...)
        --do return QSlider.new('Horizontal') end
        local this = QWidget.new(...)
	this.__gc = function(...) print(...) io.stdout:flush() this.delete(...) end

        local slider = QSlider.new'Horizontal'
        slider:setRange(0, 99)
        slider:setValue(0)

        this:__addmethod('valueChanged(int)')
        this:__addmethod('setValue(int)', function(_, val) slider:setValue(val) end)
        QObject.connect(slider, '2valueChanged(int)', this, '2valueChanged(int)')

        local layout = QVBoxLayout.new()
        --layout:addWidget(lcd)
        layout:addWidget(slider)
        this:setLayout(layout)
        this.value = function() return slider:value() end
        this.setValue = function(_,n) return slider:setValue(n) end
        return this
end

local new_MyWidget = function(...)
        local this = QWidget.new(...)
	this.__gc = function(...) print(...) io.stdout:flush() this.delete(...) end

        local layout = QVBoxLayout.new()
        local r1, r2 = LCD_Range(), LCD_Range()
        QObject.connect(r1, '2valueChanged(int)', r2, '1setValue(int)')

        layout:addWidget(r1)
        layout:addWidget(r2)
	for i=1, 3 do
		r2 = r1
		r1 = LCD_Range()
		layout:addWidget(r1)
		QObject.connect(r1, '2valueChanged(int)', r2, '1setValue(int)')
	end

        this:setLayout(layout)
        this:__addmethod('drama()', function(_) r1:setValue((r1:value() - 37) % 100)  end)
        local timer = QTimer.new()
        timer:start(1)
        QObject.connect(timer, '2timeout()', this, '1drama()')
        return this
end

app = QApplication.new(1 + select('#', ...), {arg[0], ...})
app.__gc = app.delete -- take ownership of object

widget = new_MyWidget()
widget:show()

app.exec()

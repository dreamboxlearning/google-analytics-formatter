JS_FILES = analytics.js browser_stats.js flash_stats.js
MAP_FILES = $(JS_FILES:.js=.map)

COFFEE = coffee
RM_F = rm -f
RSYNC = rsync

all: $(JS_FILES)

clean:
	$(RM_F) $(JS_FILES) $(MAP_FILES)

%.js: %.coffee
	$(COFFEE) -b -m -c $<

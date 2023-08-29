#!/bin/zsh

if [[ -d "$CI_APP_STORE_SIGNED_APP_PATH" ]]; then
	# Create "WhatToTest.txt"
	echo "Creating \"WhatToTest.txt\"..."

	TESTFLIGHT_DIR_PATH=../TestFlight
	mkdir $TESTFLIGHT_DIR_PATH

	echo "" >> $TESTFLIGHT_DIR_PATH/WhatToTest.en-US.txt
	echo "---" >> $TESTFLIGHT_DIR_PATH/WhatToTest.en-US.txt
	echo "" >> $TESTFLIGHT_DIR_PATH/WhatToTest.en-US.txt

	git fetch --deepen 5
	TZ=UTC git log -5 --date=iso-local --pretty=format:"%s (%ad) [%h]" >> $TESTFLIGHT_DIR_PATH/WhatToTest.en-US.txt

	echo "Done!"
fi

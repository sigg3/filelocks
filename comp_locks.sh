#!/bin/bash
# Comparing file lock methods (BashFAQ/045)
SCRIPT_ROOT=$( pwd "$0" )
if [ $(echo "$SCRIPT_ROOT" | wc -c) -eq 1 ] ; then
	echo "\$SCRIPT_ROOT unset. Let's not mess with /" && exit 1
fi
LOCK_FILE="$SCRIPT_ROOT/lock.file"
LOCK_DIR="$SCRIPT_ROOT/lock.dir"
COUNTERF="$SCRIPT_ROOT/counter"
REPORT="$SCRIPT_ROOT/report"
TARGET_SCRIPT="$SCRIPT_ROOT/do_no_evil.sh"
CleanUp() {
	for obsolete in "$COUNTERF" "$TARGET_SCRIPT" "$LOCK_FILE" "$REPORT" ; do
		[ -f "$obsolete" ] && rm -f "$obsolete"
	done
	[ -d "$LOCK_DIR" ] && rmdir "$LOCK_DIR"
}
#CleanUp # Remove the past

# Method 1: Using file locking
echo -e "\nTesting method 1: file locks" >> "$REPORT"
cat <<EOT > "$TARGET_SCRIPT"
#!/bin/bash
if [ -f "$LOCK_FILE" ] ; then
	exit 1 # Script already running
fi
touch "$LOCK_FILE"
echo "0" >> "$COUNTERF"
exit 0
EOT
chmod +x "$TARGET_SCRIPT"
LOOP_COUNT="0"
while [ "$LOOP_COUNT" -le 10 ] ; do
	(/bin/sh "$TARGET_SCRIPT")&
	((LOOP_COUNT++))
done
NUMBER_OF_INSTANCES=$( wc -l "$COUNTERF" | awk '{print $1;exit}' )
echo -e "$NUMBER_OF_INSTANCES instance(s) were executed successfully.\n" >> "$REPORT"
[ -f "$COUNTERF" ] && rm -f "$COUNTERF"
echo "sleeping 3 seconds" ; sleep 3

# Method 2: Using dir locking
echo "Testing method 2: dir locks" >> "$REPORT"
cat <<EOT > "$TARGET_SCRIPT"
#!/bin/bash
if mkdir "$LOCK_DIR" ; then
	echo "0" >> "$COUNTERF"
else
	exit 1 # Script already running
fi
exit 0
EOT
chmod +x "$TARGET_SCRIPT"
LOOP_COUNT="0"
while [ "$LOOP_COUNT" -le 10 ] ; do
	(/bin/sh "$TARGET_SCRIPT")&
	((LOOP_COUNT++))
done
NUMBER_OF_INSTANCES=$( wc -l "$COUNTERF" | awk '{print $1;exit}' )
echo "$NUMBER_OF_INSTANCES instance(s) were executed successfully." >> "$REPORT"
echo "sleeping 3 seconds" ; sleep 3
if [ -f "$REPORT" ] ; then
	clear
	echo "# Comparing file lock methods (BashFAQ/045) - only 1 should run"
	cat "$REPORT"
fi
CleanUp ; echo "Done." ; exit 0

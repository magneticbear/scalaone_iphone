brew install ios-sim

rm -rf podfile.lock
rm -rf pods
echo "Running pod install"
pod install
echo "Build the Integration target to run in the simulator"
xcodebuild -workspace ScalaOne.xcworkspace -scheme Integration -sdk iphonesimulator DEPLOYMENT_LOCATION=YES  DSTROOT=build DWARF_DSYM_FOLDER_PATH=build clean build

touch out.txt
OUT_FILE=out.txt
# Run the app we just built in the simulator and send its output to a file
# /path/to/MyApp.app should be the relative or absolute path to the application bundle that was built in the previous step
echo "Running KIF tests"
ios-sim launch "build/Applications/Integration.app" --retina --tall --stderr $OUT_FILE
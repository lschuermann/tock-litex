{
  # Vendor all references to the build directory or other paths in the
  # Nix store
  #
  # This is a bit hacky and tries to parse important lines of the
  # generated tcl script. There is probably a better way to do this,
  # but it works for now.
  vendorDependencies = target_name: ''
    echo "Vendoring Verilog dependencies..."
    VENDOR_DIR="./build/${target_name}/gateware/vendored"
    VENDOR_DIR_REL_PATH="./vendored"
    mkdir -p "$VENDOR_DIR"
    while IFS= read -r LINE; do
      if [[ "$LINE" =~ ^read_verilog.* ]]; then
        # Dependencies with absolute path, vendor them using relative path
        DEP_PATH="$(echo "$LINE" | sed 's/^[^{]*{\([^{}]*\)}.*/\1/')"
        BASENAME="$(basename "$DEP_PATH")"
        cp -v "$DEP_PATH" "$VENDOR_DIR/$BASENAME"
        echo "read_verilog {$VENDOR_DIR_REL_PATH/$BASENAME}" >> \
          ./build/${target_name}/gateware/${target_name}.vendored.tcl
      else
        # Use line unmodified
        echo "$LINE" >> ./build/${target_name}/gateware/${target_name}.vendored.tcl
      fi
    done < ./build/${target_name}/gateware/${target_name}.tcl
  '';
}

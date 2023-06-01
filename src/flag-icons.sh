fn_flagicons() {
  ################
  # This script creates all icons in src/lib directory.
  ######################
  GITURL="https://github.com/lipis/flag-icons"
  DIRNAME='flag-icons'
  SVGDIR='flags/4x3'
  LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-flag-icons"
  SVELTE_LIB_DIR='src/lib'
  CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
  # clone from github
  cd "${CURRENTDIR}" || exit 1
  # if there is the svgs, remove it
  if [ -d "${CURRENTDIR}" ]; then
    bannerColor "Removing the previous ${DIRNAME} dir." "blue" "*"
    rm -rf "${CURRENTDIR:?}/"*
  fi

  # clone the repo
  bannerColor "Cloning ${DIRNAME}." "green" "*"
  npx tiged "${GITURL}/${SVGDIR}" >/dev/null 2>&1 || {
    echo "not able to clone"
    exit 1
  }

  # For each svelte file modify contents of all file by
  bannerColor 'Modifying all files.' "blue" "*"

  # inserting script tag at the beginning and insert width={size} height={size} 
  sed -i '1s/^/<script>export let size="24"; export let role="img";<\/script>/' ./*.* && sed -i 's/viewBox=/width={size} height={size} {...$$restProps} {role} aria-label={ariaLabel} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.*

  # get textname from filename
  for filename in "${CURRENTDIR}"/*; do
    FILENAME=$(basename "${filename}" .svg | tr '-' ' ')
    # echo "${FILENAME}"
    sed -i "s;</script>;export let ariaLabel=\"flag of ${FILENAME}\" &;" "${filename}"
  done

  #  modify file names
  bannerColor 'Renaming all files in the dir.' "blue" "*"

  # rename files with number at the beginning with A
  rename -v 's{^\./(\d*)(.*)\.svg\Z}{
    ($1 eq "" ? "" : "A$1") . ($2 =~ s/\w+/\u$&/gr =~ s/-//gr) . ".svelte"
  }ge' ./*.svg >/dev/null 2>&1

  bannerColor 'Renaming is done.' "green" "*"

  bannerColor 'Modification is done in the dir.' "green" "*"

  #############################
  #    INDEX.JS PART 1 IMPORT #
  #############################
  cd "${CURRENTDIR}" || exit 1

  # Add component doc
  for file in ./*.*; do
    echo -e "\n<!--\n@component\n[Go to Document](https://svelte-flag-icons.codewithshin.com/)\n## Props\n@prop size = '24';\n@prop role = 'img';\n@prop ariaLabel = 'icon file name';\n## Event\n- on:click\n- on:keydown\n- on:keyup\n- on:focus\n- on:blur\n- on:mouseenter\n- on:mouseleave\n- on:mouseover\n- on:mouseout\n-->" >> "$file"
  done


  bannerColor 'Creating index.js file.' "blue" "*"
  
  find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
    print "export { default as " $(NF-1) " } from \047" $0 "\047;"
  }' >index.js

  bannerColor 'Added export to index.js file.' "green" "*"

  # clean up
  rm -rf "${CURRENTDIR}/${DIRNAME}"
  rm -rf "${CURRENTDIR}/${SVGDIR}"

  bannerColor 'All done.' "green" "*"

  bannerColor 'All icons are created in the src/lib directory.' 'magenta' '='
}

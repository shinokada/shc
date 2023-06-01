fn_simple() {
    ###########################################################
    # This script creates simple-icons. 
    ###########################################################
    GITURL="git@github.com:simple-icons/simple-icons.git"
    tiged='simple-icons/simple-icons/icons'
    DIRNAME='simple-icons'
    ICONDIR='icons'
    SVELTE_LIB_DIR='src/lib'
    LOCAL_REPO_NAME="$HOME/Svelte/SVELTE-ICON-FAMILY/svelte-simples"
    CURRENTDIR="${LOCAL_REPO_NAME}/${SVELTE_LIB_DIR}"
    
    if [ ! -d ${CURRENTDIR} ]; then
      mkdir ${CURRENTDIR} || exit 1
    else
      bannerColor "Removing the previous ${CURRENTDIR} dir." "blue" "*"
      rm -rf "${CURRENTDIR:?}/"
      # create a new
      mkdir -p "${CURRENTDIR}"
    fi
    
    cd "${CURRENTDIR}" || exit 1

    # clone it
    # clone the repo
    bannerColor "Cloning ${DIRNAME}." "green" "*"
    npx tiged "${tiged}" >/dev/null 2>&1 || {
      echo "not able to clone"
      exit 1
    }

    ######################### 
    #        ICONS      #
    #########################
    bannerColor 'Changing dir to icons dir' "blue" "*"
    cd "${CURRENTDIR}" || exit

    bannerColor 'Removing all files starting with a number.' "blue" "*"
    find . -type f -name "[0-9]*"  -exec rm {} \;
    bannerColor 'Done.' "green" "*"
    
    #  modify file names
    bannerColor 'Renaming all files in the dir.' "blue" "*"
    # rename file names 
    rename -v 's/./\U$&/;s/-(.)/\U$1/g;s/\.svg$/.svelte/' -- *.svg  > /dev/null 2>&1
    bannerColor 'Renaming is done.' "green" "*"

    # removing width="24" height="24"
    sed -i 's/role="img"//' ./*.*
    
    # For each svelte file modify contents of all file
    bannerColor 'Modifying all files.' "blue" "*"

    # Insert script tag at the beginning and insert width={size} height={size} 
    sed -i '1s/^/<script>export let size="24"; export let role="img"; export let color="#1877F2";<\/script>/' ./*.* && sed -i 's/xmlns/width={size} height={size} fill={color} &/' ./*.*

    # Insert {...$$restprops} before xmlns="http://www.w3.org/2000/svg"
    sed -i 's/xmlns=/ {...$$restProps} {role} on:click on:keydown on:keyup on:focus on:blur on:mouseenter on:mouseleave on:mouseover on:mouseout &/' ./*.*

    # Add component doc
    for file in ./*.*; do
      echo -e "\n<!--\n@component\n[Go to Document](https://svelte-simples.codewithshin.com/)\n## Props\n@prop size = '24';\n@prop role = 'img';\n@prop color = '#1877F2';\n## Event\n- on:click\n- on:keydown\n- on:keyup\n- on:focus\n- on:blur\n- on:mouseenter\n- on:mouseleave\n- on:mouseover\n- on:mouseout\n-->" >> "$file"
    done
    
    bannerColor 'Modification is done in outline dir.' "green" "*"

    bannerColor 'Creating index.js file.' "blue" "*"
    
    find . -type f -name '*.svelte' | sort | awk -F'[/.]' '{
      print "export { default as " $(NF-1) " } from \047" $0 "\047;"
    }' >index.js

    bannerColor 'Added export to index.js file.' "green" "*"

    bannerColor "Cleaning up ${CURRENTDIR}/${DIRNAME}." "blue" "*"
    
    bannerColor 'All done.' "green" "*"
}
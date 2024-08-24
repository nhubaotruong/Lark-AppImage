#!/usr/bin/env bash

# Determine if we're running inside GitHub actions.
GITHUB_RUNNING_ACTION=$GITHUB_ACTIONS

APP_NAME=Lark
VERSION=$(wget -qO- https://www.larksuite.com/api/downloads | jq -r '.versions.Linux_deb_x64.version_number' | cut -d'@' -f2)

if [ "$GITHUB_RUNNING_ACTION" == true ]; then
    # If we check only for version here.
    RELEASE_VERSION=$(gh api -H "Accept: application/vnd.github+json" /repos/"$GH_USER"/"$GH_REPO"/releases/latest | jq -r ".name" | sed 's/'"$APP_NAME"' AppImage //g')

    if [ "$VERSION" = "$RELEASE_VERSION" ]; then
        echo "::set-output name=app_update_needed::false"
        echo "APP_UPDATE_NEEDED=false" >>"$GITHUB_ENV"
        # Always exit here.
        echo "No update needed. Exiting."
        exit 0
    else
        echo "::set-output name=app_update_needed::true"
        echo "Update required."
        echo "APP_UPDATE_NEEDED=true" >>"$GITHUB_ENV"
    fi
fi

wget -cO ./pkg2appimage.AppImage https://github.com/AppImageCommunity/pkg2appimage/releases/download/continuous/pkg2appimage--x86_64.AppImage
wget -cO ./appimagetool.AppImage https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage

chmod +x ./pkg2appimage.AppImage
chmod +x ./appimagetool.AppImage

if [ "$GITHUB_RUNNING_ACTION" == true ]; then
    # ARCH=x86_64 ./appimagetool.AppImage --comp gzip lark/lark.AppDir -n -u "gh-releases-zsync|$GH_USER|$GH_REPO|latest|Lark*.AppImage.zsync"
    ./pkg2appimage.AppImage lark.yml -u "gh-releases-zsync|$GH_USER|$GH_REPO|latest|Lark*.AppImage.zsync"
    echo "APP_NAME=$APP_NAME" >>"$GITHUB_ENV"
    echo "APP_SHORT_NAME=$APP_NAME" >>"$GITHUB_ENV"
    echo "APP_VERSION=$VERSION" >>"$GITHUB_ENV"
else
    ./pkg2appimage.AppImage lark.yml
fi

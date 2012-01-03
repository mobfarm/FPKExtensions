appledoc \
-h \
-d \
-u \
--docset-publisher-name "MobFarm" \
--docset-bundle-name "FastPdfKit Extensions" \
--docset-bundle-id com.mobfarm.fastpdfkit.extensions \
--docset-publisher-id "com.mobfarm" \
--keep-intermediate-files \
-o ~/git/FPKExtensions/Docs \
-t ~/git/appledoc/Templates \
-p "FastPdfKit Extensions" \
-c "MobFarm" \
--company-id com.mobfarm \
--docset-feed-url "http://doc.fastpdfkit.com/Extensions/docset.atom" \
--docset-package-url "http://doc.fastpdfkit.com/Extensions/docset.xar" \
--docset-atom-filename "docset.atom" \
--docset-package-filename "docset.xar" \
-v "1.0.0" \
--index-desc ~/git/FPKExtensions/FPKShared/FPKShared/Resources/index.md \
--ignore *.embeddedframework \
--include ~/git/FPKExtensions/FPKShared/FPKShared/Resources/README-template.md \
--include ~/git/FPKExtensions/FPKShared/FPKShared/Resources/FPKExtension-template.md \
--include ~/git/FPKExtensions/FPKShared/FPKShared/Resources/fpk-icon.png \
--include ~/git/FPKExtensions/FPKShared/FPKShared/Resources/rename-project.png \
--include ~/git/FPKExtensions/FPKPayPal/FPK/fpkpaypal.png \
~/git/FPKExtensions
echo "Copying Documentation to the Xserve"
scp -r ~/git/FPKExtensions/Docs/html/* mobfarm.eu:/Library/WebServer/docs/FastPdfKit/Extensions/
echo "Publishing Docset"
scp -r ~/git/FPKExtensions/Docs/publish/* mobfarm.eu:/Library/WebServer/docs/FastPdfKit/Extensions/
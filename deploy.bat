@echo off
REM === Configuration Java OBLIGATOIRE ===
set JAVA_HOME=C:\Program Files\Java\jdk-17_windows-x64_bin\jdk-17.0.12
set JRE_HOME=%JAVA_HOME%
set PATH=%JAVA_HOME%\bin;%PATH%

REM ==================================================
REM   DÉPLOIEMENT AUTOMATIQUE TOMCAT - MVC FRAMEWORK
REM ==================================================
setlocal EnableDelayedExpansion

REM === Configurations ===
set TOMCAT_PATH=D:\apache-tomcat-9.0.82\apache-tomcat-9.0.82
set WAR_NAME=test-mvc-app
set PROJECT_DIR=%~dp0
set TARGET_WAR=%PROJECT_DIR%test-project\target\%WAR_NAME%.war

color 0A
echo.
echo ==================================================
echo    DÉPLOIEMENT %WAR_NAME%.war DANS TOMCAT
echo ==================================================
echo.
echo 🔧 Configuration Java:
echo    JAVA_HOME: %JAVA_HOME%
echo    JRE_HOME:  %JRE_HOME%
echo.

REM === Vérification de Tomcat ===
echo 🔍 Vérification de Tomcat...
if not exist "%TOMCAT_PATH%\bin\startup.bat" (
    echo ❌ ERREUR : Tomcat non trouvé à l'emplacement: %TOMCAT_PATH%
    echo.
    echo 💡 Modifiez la variable TOMCAT_PATH dans ce fichier .bat
    echo 💡 Ou installez Tomcat à: D:\apache-tomcat-10.1.28
    echo.
    pause
    exit /b 1
)

REM === Vérification de Java ===
echo 🔍 Vérification de Java...
java -version >nul 2>&1
if errorlevel 1 (
    echo ❌ ERREUR : Java non accessible. Vérifiez JAVA_HOME
    echo 💡 JAVA_HOME actuel: %JAVA_HOME%
    pause
    exit /b 1
)
echo ✅ Java correctement configuré

REM === Étape 1: Builder le Framework ===
echo.
echo 🔨 ÉTAPE 1: Construction du Framework...
cd /d "%PROJECT_DIR%framework"
call mvn clean install

if errorlevel 1 (
    echo ❌ ERREUR : Échec de la construction du framework
    pause
    exit /b 1
)
echo ✅ Framework construit avec succès!

REM === Étape 2: Builder l'Application ===
echo.
echo 🌐 ÉTAPE 2: Construction de l'application test...
cd /d "%PROJECT_DIR%test-project"
call mvn clean package

if errorlevel 1 (
    echo ❌ ERREUR : Échec de la construction de l'application
    pause
    exit /b 1
)

REM === Vérification du fichier WAR ===
if not exist "%TARGET_WAR%" (
    echo ❌ ERREUR : Le fichier %WAR_NAME%.war n'a pas été généré !
    echo 📁 Emplacement attendu: %TARGET_WAR%
    pause
    exit /b 1
)
echo ✅ Fichier WAR généré: %TARGET_WAR%

REM === Étape 3: Arrêt de Tomcat (si en cours) ===
echo.
echo 🛑 ÉTAPE 3: Arrêt de Tomcat...
cd /d "%TOMCAT_PATH%\bin\"
if exist "shutdown.bat" (
    call shutdown.bat >nul 2>&1
    echo ⏳ Attente de l'arrêt de Tomcat...
    timeout /t 5 /nobreak >nul
)

REM === Étape 4: Nettoyage du déploiement précédent ===
echo.
echo 🧹 ÉTAPE 4: Nettoyage de l'ancien déploiement...
if exist "%TOMCAT_PATH%\webapps\%WAR_NAME%.war" (
    del /Q "%TOMCAT_PATH%\webapps\%WAR_NAME%.war"
)
if exist "%TOMCAT_PATH%\webapps\%WAR_NAME%" (
    rmdir /S /Q "%TOMCAT_PATH%\webapps\%WAR_NAME%" 2>nul
)

REM === Étape 5: Copie du nouveau WAR ===
echo.
echo 📋 ÉTAPE 5: Copie du nouveau .war dans Tomcat...
copy /Y "%TARGET_WAR%" "%TOMCAT_PATH%\webapps\"
if errorlevel 1 (
    echo ❌ ERREUR : Échec de la copie du fichier WAR
    pause
    exit /b 1
)
echo ✅ Fichier copié: %TOMCAT_PATH%\webapps\%WAR_NAME%.war

REM === Étape 6: Démarrage de Tomcat ===
echo.
echo 🚀 ÉTAPE 6: Démarrage de Tomcat...
cd /d "%TOMCAT_PATH%\bin\"
start "" "startup.bat"

echo ⏳ Attente du démarrage de Tomcat...
timeout /t 10 /nobreak >nul

REM === Étape 7: Vérification du déploiement ===
echo.
echo 🔍 ÉTAPE 7: Vérification du déploiement...
timeout /t 3 /nobreak >nul

echo 📊 Vérification des dossiers déployés...
if exist "%TOMCAT_PATH%\webapps\%WAR_NAME%" (
    echo ✅ Application déployée avec succès!
) else (
    echo ⚠️  Le déploiement peut prendre quelques secondes supplémentaires...
)

REM === Affichage des informations finales ===
echo.
echo ==================================================
echo   ✅ DÉPLOIEMENT TERMINÉ AVEC SUCCÈS !
echo ==================================================
echo.
echo 🌐 URLS DE TEST:
echo.
echo 1. Page d'accueil:    http://localhost:8080/%WAR_NAME%/
echo 2. Test utilisateurs: http://localhost:8080/%WAR_NAME%/users
echo 3. Test produits:     http://localhost:8080/%WAR_NAME%/products/123
echo 4. Test admin:        http://localhost:8080/%WAR_NAME%/admin/dashboard
echo 5. Test quelconque:   http://localhost:8080/%WAR_NAME%/n-importe-quoi
echo.
echo 📋 RÉSULTAT ATTENDU:
echo - Chaque URL doit afficher la page du FrontServlet
echo - L'URL complète doit être capturée et affichée
echo - Le style CSS doit être appliqué
echo.
echo ⏳ Ouverture automatique du navigateur dans 5 secondes...
timeout /t 5 /nobreak >nul

REM === Ouverture du navigateur ===
start "" "http://localhost:8080/%WAR_NAME%/"

echo.
echo 💡 Pour arrêter Tomcat: exécutez stop-tomcat.bat
echo 💡 Pour redéployer: relancez ce script
echo.
pause
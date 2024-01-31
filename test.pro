QT += core
QT -= gui

include(variables.pri)

CONFIG += c++17 console
CONFIG -= app_bundle

QMAKE_CXXFLAGS += -Wno-unknown-pragmas

INCLUDEPATH +=  $$PROJECT_DIR/external_libs/libodb/include \
                $$PROJECT_DIR

LIBS += -L$$PROJECT_DIR/external_libs/libodb/lib

LIBS += -lpq -lodb -lodb-pgsql -lodb-mysql -lodb-qt -lssl -lcrypto -lmysqlclient

SOURCES += \
        $$PROJECT_DIR/odbTest.cpp \
        $$PROJECT_DIR/odbTest-odb.cxx \
        $$PROJECT_DIR/odbTest-schema.cxx \
        main.cpp


HEADERS += \
    $$PROJECT_DIR/odbTest.h

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target


database=mysql #support: sqlite, mysql, pgsql
odbVersion=2.5.0-b.25
odbBin=$$PROJECT_DIR/external_libs/odb-$${odbVersion}/bin/odb
includeFilesForOdb=-I$$[QT_INSTALL_HEADERS] -I$$[QT_INSTALL_HEADERS]/QtCore
for(incl, INCLUDEPATH) {
    includeFilesForOdb=$${includeFilesForOdb} -I$${incl}
}
odbArgs=-x -fPIE -x -fPIC --profile qt --std c++17 -d $${database} --generate-query --generate-schema --suppress-schema-version --schema-format separate --generate-session
#---------

!isEmpty(QMAKE_ARGS) { #костыль, так как QT запускает этот файл при каждом вызове qmake. Проблема с очисткой остаётся
res = {$$system($${odbBin} --version)
message($${res})
message(@@@@@@@@@@@@@@@@@@@@@@@@@@ odb compile start $$system(date))
odbSuccess=true
for(fileToOdbCompile, HEADERS) {
    fileName=$$absolute_path($${fileToOdbCompile})
    pathToFile=$$dirname(fileName)

    fff=$$cat($${fileName})
    findOk=$$find(fff, "odb::access;")
    !isEmpty(findOk) {
        extendedOdbArgs=
        temppp=$$find(pathToFile, "cfg")
        count(temppp, 1) {
            extendedOdbArgs= --schema-name cfg
        }
        else {
            temppp=$$find(pathToFile, "data")
            count(temppp, 1) {
                extendedOdbArgs= --schema-name dt
            }
        }
        cmd=cd $${PROJECT_DIR} && $${odbBin} $${includeFilesForOdb} $${odbArgs} $${extendedOdbArgs} --output-dir $${pathToFile} $${fileToOdbCompile}
#        message($${cmd})
        res={$$system($${cmd})}
        genFile = $$replace(fileName, \.h, .xml)
        equals(res, "{}"):exists($${genFile}) {
           message(odb compile: $${fileName} - success)
           DISTFILES += $$replace(fileToOdbCompile, \.h, .xml)
        }
        else {
            message(odb compile: $${fileName} - error: $${res})
            odbSuccess=false
        }
    }
}

message(@@@@@@@@@@@@@@@@@@@@@@@@@@ odb compile end $$system(date))
}
#---------

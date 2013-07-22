# -*- coding: utf-8 -*-
import sys
import json
import re
import os
import fnmatch
import datetime
import cmd
import random
import binascii
import filecmp
import subprocess
import base64
import hashlib
import urllib.request
import xlrd

class TXGTCOMPACT:
    """TXGenericTools for Python, compact version"""
    # version 0.9a
    @classmethod
    def test(cls):
        print('test')

    # System related
    @classmethod
    def getClipboardData(cls):
        p = subprocess.Popen(['pbpaste'], stdout=subprocess.PIPE)
        retcode = p.wait()
        data = p.stdout.read()
        return data

    @classmethod
    def setClipboardData(cls, data):
        p = subprocess.Popen(['pbcopy'], stdin=subprocess.PIPE)
        p.stdin.write(data)
        p.stdin.close()
        retcode = p.wait()
        return retcode

    # String related
    @classmethod
    def isNoneOrEmpty(cls, strA):
        if strA is None:
            return True
        if strA == '':
            return True
        return False

    @classmethod
    def isStringEquals(cls, strA, strB, ignoreCaseA=False):
        if strA is None:
            if strB is None:
                return True
            else:
                return False

        if strB is None:
            return False

        if ignoreCaseA:
            if strA == strB:
                return True
            else:
                return False
        else:
            if strA.lower() == strB.lower():
                return True
            else:
                return False

        return False

    @classmethod
    def saveString(cls, strA, fileNameA, encodingA='utf-8'):
        if strA is None:
            return 'The string object is none.'

        if TXGTCOMPACT.isNoneOrEmpty(fileNameA):
            return 'File name not valid.'

        fileO = open(fileNameA, 'wb')
        if fileO is None:
            return 'Opening file failed.'

        bytesWritten = fileO.write(strA.encode(encodingA))

        fileO.close()
        if bytesWritten < len(strA):
            return 'Not all bytes written.'

        return ''

    @classmethod
    def loadString(cls, fileNameA, encodingA='utf-8'):
        if TXGTCOMPACT.isNoneOrEmpty(fileNameA):
            return None

        if not os.path.exists(fileNameA):
            return None

        fileI = open(fileNameA, 'rb')
        if fileI is None:
            return None

        byteT = fileI.read()
        fileI.close()

        strT = byteT.decode(encodingA)

        return strT

    # Parameter and switch related
    @classmethod
    def getSwitch(cls, argsA, switchStrA):
        for i, argT in enumerate(argsA):
            if argT.startswith(switchStrA):
                tmpSw = argT[len(switchStrA):]
                if tmpSw.startswith('"') and tmpSw.endswith('"'):
                    return tmpSw[1:-1]
                else:
                    return tmpSw
        return None

    @classmethod
    def getParameterByIndexOneStart(cls, argsA, idxA):
        cnt = 0
        for i, argT in enumerate(argsA):
            if argT.startswith('-'):
                continue
            cnt += 1
            if cnt == idxA:
                if argT.startswith('"') and argT.endswith('"'):
                    return argT[1:-1]
                else:
                    return argT
        return None

    # File related
    def  callback_f(downloaded_size, block_size, romote_total_size):
        per = 100.0 * downloaded_size * block_size / romote_total_size
        if per > 100:
            per = 100
        print("%.2f%% %d of %d bytes" %(per,  (downloaded_size * block_size), romote_total_size), end='\r')

    @classmethod
    def readBytesFromFile(cls, fileNameA):
        if TXGTCOMPACT.isNoneOrEmpty(fileNameA):
            return None

        if not os.path.exists(fileNameA):
            return None

        fileI = open(fileNameA, 'rb')
        if fileI is None:
            return None

        byteT = fileI.read()
        fileI.close()
        return byteT

    @classmethod
    def writeBytesToFile(cls, fileNameA, bytesA):
        if TXGTCOMPACT.isNoneOrEmpty(fileNameA):
            return 'File name not valid.'

        fileO = open(fileNameA, 'wb')
        if fileO is None:
            return None

        bytesWritten = fileO.write(bytesA)

        fileO.close()
        if bytesWritten < len(bytesA):
            return 'Not all bytes written.'

        return None

    @classmethod
    def dumpFile(cls, fileNameA, bytesCountA=0):
        if TXGTCOMPACT.isNoneOrEmpty(fileNameA):
            print('File name not valid.')
            return 'File name not valid.'

        if not os.path.exists(fileNameA):
            print('File not exists.')
            return 'File not exists.'

        fileI = open(fileNameA, 'rb')
        if fileI is None:
            print('Open file failed.')
            return 'Open file failed.'

        if bytesCountA > 0:
            byteT = fileI.read(bytesCountA)
        else:
            byteT = fileI.read()
        fileI.close()

        print(binascii.hexlify(byteT))

        return None

    # Encryption/decryption related
    @classmethod
    def getMD5ofString(cls, strA):
        if strA is None:
            return None
        m = hashlib.md5(strA.encode(encoding='utf-8'))
        return m.hexdigest()

    @classmethod
    def decryptStringByBase64(cls, strA):
        if strA is None:
            return None

        rT = base64.b64decode(strA.encode('utf-8'))
        if rT is not None:
            return rT

        return None

argc = len(sys.argv)

if argc < 2:
    print('Usage: python3 mergeexcel.py DIRECTORY_NAME [OUTPUT_FILE_NAME] [-fFILE_NAME_FILTER]...\n')
    print('  Default output file name is mergeResult.csv.\n')
    sys.exit(0)

dirName = TXGTCOMPACT.getParameterByIndexOneStart(sys.argv, 2)
fileNameT = TXGTCOMPACT.getParameterByIndexOneStart(sys.argv, 3)
filterT = TXGTCOMPACT.getSwitch(sys.argv, '-f')

#if TXGTCOMPACT.isNoneOrEmpty(fileNameT):
 #   fileNameT = 'mergeResult.csv'

if dirName is not None:
    if os.path.exists(dirName):
        if os.path.isdir(dirName):
            filest = os.listdir(dirName)

            if filest is None:
                print('No files in this directory.')
            else:
                lent = len(filest)
                for i in range(lent - 1, -1, -1):
                    if not (os.path.isfile(os.path.join(dirName, filest[i])) and (True if TXGTCOMPACT.isNoneOrEmpty(filterT) else fnmatch.fnmatch(filest[i], filterT))):
                        print('Skipping ' + filest[i] + '...\n')
                        del filest[i]

                filest.sort()

                fileNumber = len(filest)

                

                for i in range(0, (int(fileNumber))):
                    print(os.path.join(dirName, filest[i]))
                    txtFile = open(filest[i]+'.tsv', mode='w', encoding='utf-8')
                    print('Processing ' + filest[i] + '...')
                    #txtFile.write('***' + filest[i] + '\n');
                    wb = xlrd.open_workbook(os.path.join(dirName, filest[i]))

                    # sheet = wb.sheet_by_index(0)
                    for sheetT in wb.sheets():
                        for j in range(0, sheetT.nrows):
                            for k in range(sheetT.row_len(j) ):
                               
                                if k < 1:
                                    if TXGTCOMPACT.isNoneOrEmpty(str(sheetT.cell(j, k).value).strip()):
                                        break
                                    txtFile.write(str(sheetT.cell(j, k).value))
                                else:
                                    txtFile.write('\t' + str(sheetT.cell(j, k).value))
                                    if k == (sheetT.row_len(j) - 1):
                                        txtFile.write('\n')

                    # cellt = sheet.cell(0, 0).value
                    # print(rowt);
                        txtFile.write('\n')

                    txtFile.close()
                print(str(fileNumber) + ' file(s) processed.')
        else:
            print('Not a directory.')
    else:
        print('Directory not exists.')
else:
    print('Not enough parameters')

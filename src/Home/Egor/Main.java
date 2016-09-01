package Home.Egor;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Arrays;

public class Main {

    public static boolean zipSignatureFound(byte[] data, int dataPos) {
        // According to:
        // http://stackoverflow.com/questions/19120676/how-to-detect-type-of-compression-used-on-the-file-if-no-file-extension-is-spe
        // zip data block starts with 0x50, 0x4b, 0x03, 0x04.
        if (data[dataPos] != 0x50)
            return false;
        if (data[dataPos + 1] != 0x4b)
            return false;
        if (data[dataPos + 2] != 0x03)
            return false;
        if (data[dataPos + 3] != 0x04)
            return false;
        return true;
    }

    public static void saveToFile(byte[] data, int dataPos, int dataLength, int fileNumber) throws IOException {
        String filePath = String.format("D:\\3 курс\\ОС\\Лекции\\out\\%d.zip", fileNumber);
        Path path = Paths.get(filePath);
        byte[] dataToSave = Arrays.copyOfRange(data, dataPos, dataPos + dataLength);
        Files.write(path, dataToSave);
    }

    public static void doEverything() throws IOException {
        Path path = Paths.get("D:/3 курс/ОС/Лекции/T1-1_osn_concept.wex");
        byte[] data = Files.readAllBytes(path);
        //System.out.printf("%02X %02X ", data[0], data[1]);
        int fileNumber = 0;
        for (int i = 0; i < data.length - 3; i++) {
            if (!zipSignatureFound(data, i))
                continue;
            int length = 10;
            fileNumber++;
            saveToFile(data, i, length, fileNumber);
        }
    }

    public static void main(String[] args) {
        try {
            doEverything();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

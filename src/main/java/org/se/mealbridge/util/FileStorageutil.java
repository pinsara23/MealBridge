package org.se.mealbridge.util;

import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Component
public class FileStorageutil {

    private final Path uploadPath = Paths.get("uploads");

    public FileStorageutil() {
        try{
            Files.createDirectories(uploadPath);
        } catch (IOException e) {
            throw new RuntimeException(e.getMessage());
        }
    }

    public String saveFile(MultipartFile file){
        try{
            //random name for file name
            String fileName = UUID.randomUUID().toString()+"_"+file.getOriginalFilename();

            //save to  disk
            Path targetLocation = this.uploadPath.resolve(fileName);
            Files.copy(file.getInputStream(),targetLocation, StandardCopyOption.REPLACE_EXISTING);

            return fileName;

        } catch (IOException e) {
            throw new RuntimeException(e.getMessage());
        }
    }
}

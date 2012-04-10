package org.franca.core.framework;

import java.io.File;
import java.io.IOException;
import java.util.List;

import com.google.common.collect.Lists;

public class ModelFileFinder {

	private List<String> extensions;
	
	public ModelFileFinder (List<String> extensions) {
		this.extensions = extensions;
	}
	
	public ModelFileFinder (String extension) {
		this.extensions = Lists.newArrayList(extension);
	}

	
	/**
	 * Collect all model files in a given directory subtree.
	 * 
	 * @param folderName the subtree root
	 * @return the list of model files
	 * @throws IOException
	 */
	public List<String> getSourceFiles (String folderName) throws IOException {
		List<String> result = Lists.newArrayList();
		File folder = new File(folderName);
		for (String s : folder.list()) {
			File f = new File(folder.getAbsolutePath() + '/' + s);
			String relativePath = folderName + '/' + s;
			if (isModelFile(f)) {
				result.add(relativePath);
			}
			else if (f.isDirectory()) {
				result.addAll(getSourceFiles(relativePath));
			}
		}		
		return result;
	}
	
	private boolean isModelFile (File f) {
		if (! f.isFile())
			return false;
		
		for(String ext : extensions) {
			if (f.getName().endsWith("." + ext))
				return true;
		}

		return false;
	}
}

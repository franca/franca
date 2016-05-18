package org.franca.core.franca.impl;

import org.apache.commons.lang.StringEscapeUtils;
import org.franca.core.franca.FAnnotation;
import org.franca.core.franca.FAnnotationType;

public class FAnnotationAuxImpl {
	private static final String SEP = ":";

	public static FAnnotationType getType (String raw) {
		if (raw == null)
			return null;

		int sep = raw.indexOf(SEP);
		if (sep<0)
			return null;
		
		sep--;
		while (Character.isWhitespace(raw.charAt(sep)))
			sep--;

		String anno = raw.substring(0, sep+1);
		FAnnotationType at = FAnnotationType.get(anno);
		return at;
	}

	public static String getComment (String raw) {
		if (raw == null)
			return null;
		
		int sep = raw.indexOf(SEP);
		if (sep<0)
			return null;
		
		sep++;
		while (sep < raw.length() && Character.isWhitespace(raw.charAt(sep)))
			sep++;

		String comment = raw.substring(sep);
		return comment.replace("\\*", "*").replace("\\@", "@");
	}

	public static void setType (FAnnotation host, FAnnotationType type) {
		String comment = getComment(host.getRawText());
		if (comment==null)
			comment = "";
		
		host.setRawText(buildRawText(type, comment));
	}

	public static void setComment (FAnnotation host, String comment) {
		FAnnotationType type = getType(host.getRawText());
		host.setRawText(buildRawText(type, comment));
	}
	
	private static String buildRawText (FAnnotationType type, String comment) {
		return (type==null ? "@undefined" : type.getLiteral()) + " " + SEP + " " + comment;
	}
}

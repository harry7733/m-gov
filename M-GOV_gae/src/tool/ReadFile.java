package tool;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;


public class ReadFile {

	public static void main(String args[]) throws IOException {
		System.out.println(ReadFile.read("/Users/wildmind5/Documents/workspace/YellowEasy/src/test.in"));
	}

	public static String read(String path) {
		FileReader fr = null;
		String res="";
		try {
			fr = new FileReader(path);
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		BufferedReader bfr = new BufferedReader(fr);

		String str;
		try {
			while ((str = bfr.readLine()) != null) {
				res += str+'\n';
			}
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return res;
	}
}

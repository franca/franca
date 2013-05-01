package org.franca.core.dsl.ui.util;

import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.console.ConsolePlugin;
import org.eclipse.ui.console.IConsole;
import org.eclipse.ui.console.IConsoleConstants;
import org.eclipse.ui.console.IConsoleManager;
import org.eclipse.ui.console.IConsoleView;
import org.eclipse.ui.console.MessageConsole;
import org.eclipse.ui.console.MessageConsoleStream;

public class SpecificConsole {

	private Shell shell = null;
	private MessageConsole console = null;
	private MessageConsoleStream out = null;
	private MessageConsoleStream err = null;

	public SpecificConsole(String consoleName) {
		init(consoleName, null);
	}

	public SpecificConsole (String consoleName, Shell shell) {
		init(consoleName, shell);
	}

	private void init(String consoleName, Shell shell) {
		this.shell = shell;
        console = findConsole(consoleName);
        console.clearConsole();
        revealConsole(console);
	}


	public MessageConsoleStream getOut() {
		if (out==null) {
			out = console.newMessageStream();
		}
		return out;
	}

	public MessageConsoleStream getErr() {
		if (err==null) {
			err = console.newMessageStream();
			if (shell!=null)
				err.setColor(shell.getDisplay().getSystemColor(SWT.COLOR_RED));
		}
		return err;
	}


	private MessageConsole findConsole(String name) {
    	ConsolePlugin plugin = ConsolePlugin.getDefault();
    	IConsoleManager conMan = plugin.getConsoleManager();
    	IConsole[] existing = conMan.getConsoles();
    	for (int i = 0; i < existing.length; i++)
    		if (name.equals(existing[i].getName()))
    			return (MessageConsole) existing[i];
    	//no console found, so create a new one
    	MessageConsole myConsole = new MessageConsole(name, null);
    	conMan.addConsoles(new IConsole[]{myConsole});
    	return myConsole;
    }

    private void revealConsole (MessageConsole console) {
        // reveal console (or ensure that its revealed)
        IWorkbenchPage page = PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage();
        String id = IConsoleConstants.ID_CONSOLE_VIEW;
        try {
            IConsoleView view = (IConsoleView) page.showView(id);
            view.display(console);
        } catch (Exception e) {
        	System.err.println(e.getMessage());
        }
    }
}

package org.franca.core.ui.addons.wizard;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Status;
import org.eclipse.jdt.core.IJavaElement;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.IPackageFragment;
import org.eclipse.jdt.core.IPackageFragmentRoot;
import org.eclipse.jdt.core.JavaConventions;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.jdt.core.JavaModelException;
import org.eclipse.jdt.internal.corext.util.JavaConventionsUtil;
import org.eclipse.jdt.ui.wizards.NewTypeWizardPage;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.xtext.ui.preferences.StatusInfo;
import org.franca.core.ui.addons.Activator;

@SuppressWarnings("restriction")
public class NewFrancaIDLFileWizardContainerConfigurationPage extends NewTypeWizardPage {

    private Text fileText;
    private static final String TITLE = "Franca IDL file Wizard";
    private static final String THE_GIVEN_FILE_ALREADY_EXISTS = "The given file already exists!";
    private static final String DEFAULT_FILE_NAME = "";
    private static final String SOURCE_FOLDER_ERROR = "You must specify a valid source folder!";
    private static final String FILE_NAME_ERROR = "File name must be specified!";
    private static final String FILE_NAME_NOT_VALID = "File name must be valid!";
    private static final String FILE_EXTENSION_ERROR = "File extension must be \"fidl\"!";
    private static final String DEFAULT_PACKAGE_WARNING = "The use of default package is discouraged.";
    private static final String PACKAGE_NAME_WARNING = "Only lower case package names supported.";
    private static final String FILE_EXTENSION = "fidl";

    public NewFrancaIDLFileWizardContainerConfigurationPage() {
        super(false, FILE_EXTENSION);
        setTitle(TITLE);
    }

    /**
     * Initialization based on the current selection.
     * 
     * @param selection
     *            the current selection in the workspace
     */
    public void init(IStructuredSelection selection) {
        IJavaElement jElement = getInitialJavaElement(selection);
        initContainerPage(jElement);

        if (jElement != null) {
            IPackageFragment pack = (IPackageFragment) jElement.getAncestor(IJavaElement.PACKAGE_FRAGMENT);
            setPackageFragment(pack, true);
        }

        packageChanged();
    }

    @Override
    public void createControl(Composite parent) {
        initializeDialogUnits(parent);

        Composite composite = new Composite(parent, SWT.NONE);
        composite.setFont(parent.getFont());

        int nColumns = 4;

        GridLayout layout = new GridLayout();
        layout.numColumns = nColumns;
        composite.setLayout(layout);

        createContainerControls(composite, nColumns);
        createPackageControls(composite, nColumns);

        Label label = new Label(composite, SWT.NULL);
        label.setText("&File name:");
        fileText = new Text(composite, SWT.BORDER | SWT.SINGLE);
        fileText.setText(DEFAULT_FILE_NAME);
        GridData gd_1 = new GridData(GridData.FILL_HORIZONTAL);
        gd_1.horizontalSpan = 3;
        fileText.setLayoutData(gd_1);
        fileText.addModifyListener(new ModifyListener() {
            public void modifyText(ModifyEvent e) {
                validatePage();
            }
        });

        setControl(composite);

        validatePage();
    }

    @Override
    protected void handleFieldChanged(String fieldName) {
        super.handleFieldChanged(fieldName);
        validatePage();
    }

    /**
     * Used to validate the page.
     * 
     * Note that because of policy restrictions, a wizard must not come up with an error.
     * 
     */
    private void validatePage() {
        IStatus packageStatus = validatePackageName(getPackageText());
        StatusInfo si = new StatusInfo(packageStatus.getSeverity(), packageStatus.getMessage());
        String containerPath = getPackageFragmentRootText();
        IWorkspaceRoot root = ResourcesPlugin.getWorkspace().getRoot();
        IResource containerResource = root.findMember(new Path(containerPath));

        if (containerPath.matches("") || containerResource == null) {
            si.setError(SOURCE_FOLDER_ERROR);
        }

        if (fileText != null) {

            String fileName = fileText.getText();
            String packageName = getPackageText().replaceAll("\\.", "/");

            if (root.findMember(new Path(containerPath + "/" + packageName + "/" + fileText.getText())) != null) {
                si.setError(THE_GIVEN_FILE_ALREADY_EXISTS);
            }

            if (fileName.length() == 0) {
                si.setError(FILE_NAME_ERROR);
            }

            if (fileName.replace('\\', '/').indexOf('/', 1) > 0) {
                si.setError(FILE_NAME_NOT_VALID);
            }

            boolean wrongExtension = false;

            if (!fileName.contains(".")) {
                wrongExtension = true;
            } else {
                int dotLoc = fileName.lastIndexOf('.');
                String ext = fileName.substring(dotLoc + 1);
                wrongExtension = !ext.equalsIgnoreCase(FILE_EXTENSION);

                String name = fileName.substring(0, dotLoc);
                IStatus nameValidatorStatus = JavaConventions.validateTypeVariableName(name, JavaCore.VERSION_1_6,
                        JavaCore.VERSION_1_6);
                if (nameValidatorStatus.getSeverity() == IStatus.ERROR) {
                    si.setError(String.format("Filename %s is not a valid Java type name.", name));
                }
            }

            if (wrongExtension) {
                si.setError(FILE_EXTENSION_ERROR);
            }
        }

        if (si.getSeverity() == IStatus.OK) {
            si.setInfo("");
        }

        if (si.isError()) {
            setErrorMessage(si.getMessage());
        }

        updateStatus(si);
    }

    private IStatus validatePackageName(String text) {
        if (text == null || text.isEmpty()) {
            return new Status(IStatus.WARNING, Activator.PLUGIN_ID, DEFAULT_PACKAGE_WARNING);
        }
        IJavaProject project = getJavaProject();
        if (project == null || !project.exists()) {
            return JavaConventions.validatePackageName(text, JavaCore.VERSION_1_6, JavaCore.VERSION_1_6);
        }
        IStatus status = JavaConventionsUtil.validatePackageName(text, project);
        if (!text.equalsIgnoreCase(text)) {
            return new Status(IStatus.ERROR, Activator.PLUGIN_ID, PACKAGE_NAME_WARNING);
        }
        return status;
    }

    /**
     * Returns the name of the new Franca IDL file set in the wizard.
     * 
     * @return the name of the file
     */
    public String getFileName() {
        return fileText.getText();
    }

    /**
     * Returns the name of the container set in the wizard.
     * 
     * @return the name of the container (folder)
     */
    public String getContainerName() {
        return getPackageFragmentRootText();
    }

    /**
     * Returns the name of the package set in the wizard.
     * 
     * @return the name of the package
     */
    public String getPackageName() {
        IPackageFragmentRoot root = getPackageFragmentRoot();

        IPackageFragment fragment = root.getPackageFragment(getPackageText());

        if (!fragment.exists()) {
            try {
                root.createPackageFragment(getPackageText(), true, new NullProgressMonitor());
            } catch (JavaModelException e) {
                e.printStackTrace();
            }
        }

        return getPackageText();
    }

    public IProject getProject() {
        return this.getPackageFragmentRoot().getJavaProject().getProject();
    }
}

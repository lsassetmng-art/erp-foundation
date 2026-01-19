package app.ui.viewmodel;

public abstract class BaseViewModel {

    protected void executeSafe(Runnable action) {
        try {
            action.run();
        } catch (IllegalArgumentException e) {
            onValidationError(e.getMessage());
        } catch (Exception e) {
            onSystemError(e);
        }
    }

    protected abstract void onValidationError(String message);
    protected abstract void onSystemError(Exception e);
}

package app.ui.viewmodel;

public abstract class BaseViewModel {

    public interface UiCallbacks {
        void onValidationError(String fieldId, String message);
        void onSystemError(Exception e);
        void onSuccess();
    }

    protected final UiCallbacks ui;

    protected BaseViewModel(UiCallbacks ui) {
        this.ui = ui;
    }

    protected final void executeSafe(Runnable action) {
        try {
            action.run();
        } catch (IllegalArgumentException e) {
            // Validation error
            ui.onValidationError("unknown", e.getMessage());
        } catch (Exception e) {
            ui.onSystemError(e);
        }
    }
}

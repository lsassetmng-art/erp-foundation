package app.ui.common;

/**
 * BaseViewModel
 *
 * - Android依存なし
 * - 状態管理のみ
 */
public abstract class BaseViewModel {

    private boolean loading;
    private String errorMessage;

    public boolean isLoading() {
        return loading;
    }

    protected void setLoading(boolean loading) {
        this.loading = loading;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    protected void setErrorMessage(String msg) {
        this.errorMessage = msg;
    }
}

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VM_DIR = ROOT / "app/src/main/java/app/ui/viewmodel"
VM_DIR.mkdir(parents=True, exist_ok=True)

code = """package app.ui.viewmodel;

public abstract class BaseViewModel {

    protected <T> void executeSafe(Callable<T> action) {
        try {
            action.call();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public interface Callable<T> {
        T call() throws Exception;
    }
}
"""
(Base := VM_DIR / "BaseViewModel.java").write_text(code, encoding="utf-8")
print("OK: ViewModel executeSafe generated")

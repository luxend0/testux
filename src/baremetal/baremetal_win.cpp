#include "baremetal/baremetal.h"

#include <QCoreApplication>
#include <QDir>
#include <QProcess>
#include <QSettings>
#include <QWinEventNotifier>

#include <windows.h>

#include <shellapi.h> // needs windows.h first

namespace {

constexpr auto RunOnceKey =
    R"(HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce)";
constexpr auto RunOnceValue = "Testux";

// Quotes one argument so that CommandLineToArgvW, which powershell.exe uses to split its
// command line, returns it unchanged.
QString quoteArgument(const QString &argument)
{
    if (!argument.isEmpty() && !argument.contains(' ') && !argument.contains('\t') &&
        !argument.contains('"'))
        return argument;

    QString quoted = "\"";
    int backslashes = 0;
    for (const QChar c : argument) {
        if (c == '\\') {
            ++backslashes;
            continue;
        }
        // Backslashes only escape when a quote follows them.
        quoted += QString(c == u'"' ? backslashes * 2 + 1 : backslashes, u'\\');
        quoted += c;
        backslashes = 0;
    }
    quoted += QString(backslashes * 2, u'\\');
    quoted += '"';
    return quoted;
}

std::wstring powerShellPath()
{
    wchar_t system[MAX_PATH];
    const UINT length = GetSystemDirectoryW(system, MAX_PATH);
    return std::wstring(system, length) + L"\\WindowsPowerShell\\v1.0\\powershell.exe";
}

} // namespace

bool BareMetalPlatform::supported()
{
    FIRMWARE_TYPE type = FirmwareTypeUnknown;
    return GetFirmwareType(&type) && type == FirmwareTypeUefi;
}

QString BareMetalPlatform::dataDir()
{
    QString programData = qEnvironmentVariable("ProgramData");
    if (programData.isEmpty())
        programData = "C:/ProgramData";
    return QDir(QDir::fromNativeSeparators(programData)).filePath("Testux");
}

bool BareMetalPlatform::runElevatedScript(const QString &scriptPath, const QStringList &arguments,
                                          QObject *context, std::function<void(int)> finished,
                                          QString *error)
{
    const QStringList parameters =
        QStringList{"-NoProfile", "-NonInteractive", "-ExecutionPolicy",
                    "Bypass",     "-File",           QDir::toNativeSeparators(scriptPath)} +
        arguments;
    const std::wstring program = powerShellPath();
    const std::wstring parameterLine = commandLine(parameters).toStdWString();

    SHELLEXECUTEINFOW info = {};
    info.cbSize = sizeof(info);
    info.fMask = SEE_MASK_NOCLOSEPROCESS | SEE_MASK_NOASYNC;
    info.lpVerb = L"runas";
    info.lpFile = program.c_str();
    info.lpParameters = parameterLine.c_str();
    info.nShow = SW_HIDE;

    if (!ShellExecuteExW(&info)) {
        const DWORD code = GetLastError();
        *error =
            code == ERROR_CANCELLED
                ? QCoreApplication::translate(
                      "BareMetal", "Testux needs administrator rights for this step and the "
                                   "request was declined.")
                : QCoreApplication::translate("BareMetal", "Could not start PowerShell (error %1).")
                      .arg(code);
        return false;
    }
    if (!info.hProcess) {
        *error = QCoreApplication::translate("BareMetal", "PowerShell did not start.");
        return false;
    }

    auto *notifier = new QWinEventNotifier(info.hProcess, context);
    QObject::connect(notifier, &QWinEventNotifier::activated, context,
                     [notifier, finished](HANDLE process) {
                         DWORD exitCode = 0;
                         GetExitCodeProcess(process, &exitCode);
                         notifier->setEnabled(false);
                         notifier->deleteLater();
                         CloseHandle(process);
                         finished(int(exitCode));
                     });
    return true;
}

bool BareMetalPlatform::rebootNow(QString *error)
{
    if (QProcess::startDetached("shutdown.exe", {"/r", "/t", "0"}))
        return true;
    *error = QCoreApplication::translate("BareMetal",
                                         "Windows refused to restart. Please restart manually.");
    return false;
}

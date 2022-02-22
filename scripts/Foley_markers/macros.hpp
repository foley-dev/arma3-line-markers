#define DOUBLES(var1,var2) var1##_##var2
#define QUOTE(var1) #var1
#define NAMESPACE Foley_markers
#define GVAR(var1) DOUBLES(NAMESPACE,var1)
#define QGVAR(var1) QUOTE(GVAR(var1))
#define BASE_DIR "scripts\Foley_markers\"

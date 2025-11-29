Module['locateFile'] = function(path, prefix) {
    if (path.endsWith('.wasm')) {
        if (typeof Module['wasmBinaryFile'] === 'string') {
            return Module['wasmBinaryFile'];
        }
        return prefix + path;
    }
    return prefix + path;
};

Module['onRuntimeInitialized'] = function() {
    if (typeof Module['onReady'] === 'function') {
        Module['onReady']();
    }
};

Module['printErr'] = function(text) {
    if (typeof Module['onError'] === 'function') {
        Module['onError'](text);
    } else {
        console.error('DartLLM:', text);
    }
};

Module['print'] = function(text) {
    if (typeof Module['onLog'] === 'function') {
        Module['onLog'](text);
    } else {
        console.log('DartLLM:', text);
    }
};

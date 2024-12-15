window.addEventListener('message', (ev) => {
    const { type, data } = ev.data;

    if (type === 'devvit-message') {
        const { message } = data;

        if (message.type == 'playShareLevel') {
            const { level } = message.data;
            var meta = document.createElement('meta');
            meta.setAttribute('name', 'playShareLevelTag');
            meta.setAttribute('content', '' + level);
            document.getElementsByTagName('head')[0].appendChild(meta);
        }
    }
});

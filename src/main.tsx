import './createPost.js';

import { Devvit, useState } from '@devvit/public-api';

type WebViewMessage =
  | {
    type: 'initialData';
    data: { username: string; currentCounter: number };
  }
  | {
    type: 'setCounter';
    data: { newCounter: number };
  }
  | {
    type: 'updateCounter';
    data: { currentCounter: number };
  };

Devvit.configure({
  redditAPI: true,
  redis: true,
});

// Add a custom post type to Devvit
Devvit.addCustomPostType({
  name: 'Zero Block',
  height: 'tall',
  render: (context) => {
    const [webviewVisible, setWebviewVisible] = useState(false);
    const onLaunchGame = () => {
      setWebviewVisible(true);
      context.ui.webView.postMessage('myWebView', {});
    };

    const onLaunchCustomGame = () => {
      setWebviewVisible(true);
      context.ui.webView.postMessage('myWebView', {
        type: 'playShareLevel',
        data: {
          level: 'eyJuYW1lIjoiMyIsInRpbGVzIjpbeyJ0eXBlIjoyLCJ2ZWN0b3IiOnsieCI6Mi4wLCJ5Ijo2LjB9LCJkYXRhIjoiLTEyMyIsImxpZmV0aW1lIjoxfSx7InR5cGUiOjIsInZlY3RvciI6eyJ4IjozLjAsInkiOjYuMH0sImRhdGEiOiItMSIsImxpZmV0aW1lIjoxfV19',
        },
      });
    };

    // Render the custom post type
    return (
      <vstack grow padding="small">
        <vstack
          grow={!webviewVisible}
          height={webviewVisible ? '0%' : '100%'}
          alignment="middle center"
        >
          <text size="xlarge" weight="bold">
            Zero Block
          </text>
          <spacer />
          <vstack alignment="start middle">
          </vstack>
          <spacer />
          <button onPress={onLaunchGame}>Launch Game</button>
          <button onPress={onLaunchCustomGame}>Launch Custom Game</button>
        </vstack>
        <vstack grow={webviewVisible} height={webviewVisible ? '100%' : '0%'}>
          <vstack border="thick" borderColor="black" height={webviewVisible ? '100%' : '0%'}>
            <webview
              id="myWebView"
              url="index.html"
              onMessage={(msg) => { }}
              grow
              height={webviewVisible ? '100%' : '0%'}
            />
          </vstack>
        </vstack>
      </vstack>
    );
  },
});

export default Devvit;

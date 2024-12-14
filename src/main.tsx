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
    const onShowWebviewClick = () => {
      setWebviewVisible(true);
      context.ui.webView.postMessage('myWebView', {
        type: 'initialData',
        data: {
          username: '',
          currentCounter: '',
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
          <button onPress={onShowWebviewClick}>Launch Game</button>
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

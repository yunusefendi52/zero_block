import './createPost.js';

import { Devvit, JSONObject, useForm, useState } from '@devvit/public-api';

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

    const myForm = useForm(
      (data) => {
        return {
          fields: [
            {
              type: 'string',
              name: 'shareLevel',
              required: true,
              label: 'Custom Level which you copied from Custom Level menu',
              defaultValue: data?.shareLevel,
            },
          ],
        }
      },
      (values) => {
        if (values.shareLevel) {
          setWebviewVisible(true);
          context.ui.webView.postMessage('myWebView', {
            type: 'playShareLevel',
            data: {
              level: values.shareLevel,
            },
          });
        }
      }
    );

    const onLaunchCustomGame = (data?: JSONObject | undefined) => {
      context.ui.showForm(myForm, data)
    };

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
          <text size="medium" weight="regular">
            MOVE BROWN BLOCK UNTIL IT REACHES TO 0
          </text>
          <spacer />
          <vstack alignment="start middle">
          </vstack>
          <spacer />
          <button onPress={onLaunchGame}>Launch Game</button>
          <spacer />
          <button onPress={() => onLaunchCustomGame()}>Launch Custom Game</button>
        </vstack>
        <vstack grow={webviewVisible} height={webviewVisible ? '100%' : '0%'}>
          <vstack border="thick" borderColor="black" height={webviewVisible ? '100%' : '0%'}>
            <webview
              id="myWebView"
              url="index.html"
              onMessage={(msg) => {
                const { type, shareCustomLevel } = msg as {
                  type: string
                  shareCustomLevel?: string
                }
                if (type === 'actionMainMenu') {
                  setWebviewVisible(false)
                } else if (type === 'actionShowCustomGame') {
                  setWebviewVisible(false)
                  onLaunchCustomGame({
                    shareLevel: shareCustomLevel || null,
                  })
                }
              }}
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

//
//  ViewController.swift
//  ios101-project5-tumbler
//

import UIKit
import NukeExtensions

class ViewController: UIViewController, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            let post = posts[indexPath.row]
            cell.captionLabel.text = post.summary
if let photo = post.photos.first {
    let url = photo.originalSize.url
                NukeExtensions.loadImage(with: url, into: cell.postImageView)}
return cell}
    

    let refresh = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        refresh.addTarget(self, action: #selector(refreshPosts), for: .valueChanged)
            tableView.refreshControl = refresh
        
        fetchPosts()
    }
// a new method to handle refresh
    @objc func refreshPosts() {
        fetchPosts()
    }
    
    private var posts: [Post] = []
    @IBOutlet weak var tableView: UITableView!
    
    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }

            guard let data = data else {
                print("❌ Data is NIL")
                return
            }

            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)

                DispatchQueue.main.async { [weak self] in

                    let posts = blog.response.posts


                    print("✅ We got \(posts.count) posts!")
                    for post in posts {
                        print("🍏 Summary: \(post.summary)")
                    }
                 
                    self?.posts = posts
                       
                    self?.tableView.reloadData()
                                    self?.refresh.endRefreshing()
                }

            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
       
    }
}

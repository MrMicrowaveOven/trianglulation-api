class ApplicationController < ActionController::API
    RADIUS_OF_EARTH = 3963
    SIN15 = Math.sin(Math::PI/12)
    COS15 = Math.cos(Math::PI/12)
    SIN75 = Math.sin(5*Math::PI/12)
    COS75 = Math.cos(5*Math::PI/12)
    def index
        lat1, lng1, distance1 = params['lat1'].to_f, params['lng1'].to_f, params['distance1'].to_f
        lat2, lng2, distance2 = params['lat2'].to_f, params['lng2'].to_f, params['distance2'].to_f
        lat3, lng3, distance3 = params['lat3'].to_f, params['lng3'].to_f, params['distance3'].to_f
        equidistant_points1 = get_equidistant_points(lat1, lng1, distance1)
        p "Point 1:"
        p [lat1, lng1]
        p "equidistant_points1"
        p equidistant_points1
        equidistant_points2 = get_equidistant_points(lat2, lng2, distance2)
        p "Point 2:"
        p [lat2, lng2]
        p "equidistant_points2"
        p equidistant_points2
        equidistant_points3 = get_equidistant_points(lat3, lng3, distance3)
        p "Point 3:"
        p [lat3, lng3]
        p "equidistant_points3"
        p equidistant_points3

        closest_points_for_1_and_2 = get_closest_points(equidistant_points1, equidistant_points2)
        p "closest_points_for_1_and_2"
        p closest_points_for_1_and_2
        closest_points_for_all_3 = get_closest_points(closest_points_for_1_and_2, equidistant_points3)
        closest_point = get_midpoint(closest_points_for_all_3[0], closest_points_for_all_3[1])

        render json: { closest_point: closest_point }
    end

    private

    def get_equidistant_points(lat, lng, distance)
        vert_points = get_vert_points(lat, lng, distance)
        hor_points = get_hor_points(lat, lng, distance)

        north_lat = vert_points[0][0]
        east_lng = hor_points[1][1]
        vert_angular_distance = north_lat - lat
        hor_angular_distance = east_lng - lng
        diag_points = get_diag_points(lat, lng, vert_angular_distance, hor_angular_distance)
        all_30_60_points = get_30_60_points(lat, lng, vert_angular_distance, hor_angular_distance)
        all_15_75_points = get_15_75_points(lat, lng, vert_angular_distance, hor_angular_distance)
        p "first 8"
        p vert_points + hor_points + diag_points
        p "last 8"
        p all_30_60_points
        p "15s and 75s"
        p all_15_75_points
        vert_points + hor_points + diag_points + all_30_60_points + all_15_75_points
    end

    def get_vert_points(lat, lng, distance)
        degrees_to_move_radians = distance / RADIUS_OF_EARTH
        degrees_to_move = degrees_to_move_radians * 180 / Math::PI
        [[lat + degrees_to_move, lng], [lat - degrees_to_move, lng]]
    end

    def get_hor_points(lat, lng, distance)
        lat_in_radians = lat * Math::PI / 180
        radius_at_latitude = RADIUS_OF_EARTH * Math.cos(lat_in_radians)
        degrees_to_move_radians = distance / radius_at_latitude
        degrees_to_move = degrees_to_move_radians * 180 / Math::PI
        [[lat, lng - degrees_to_move], [lat, lng + degrees_to_move]]
    end

    def get_diag_points(lat, lng, vert_angular_distance, hor_angular_distance)
        vert_angular_distance_of_diags = vert_angular_distance / Math.sqrt(2)
        hor_angular_distance_of_diags = hor_angular_distance / Math.sqrt(2)
        [
            [lat + vert_angular_distance_of_diags, lng + hor_angular_distance_of_diags],
            [lat - vert_angular_distance_of_diags, lng + hor_angular_distance_of_diags],
            [lat - vert_angular_distance_of_diags, lng - hor_angular_distance_of_diags],
            [lat + vert_angular_distance_of_diags, lng - hor_angular_distance_of_diags],
        ]
    end

    def get_30_60_points(lat, lng, vert_angular_distance, hor_angular_distance)
        vert_angular_distance_of_30 = vert_angular_distance / 2
        hor_angular_distance_of_30 = hor_angular_distance * Math.sqrt(3)/2

        all_30_points = [
            [lat + vert_angular_distance_of_30, lng + hor_angular_distance_of_30],
            [lat - vert_angular_distance_of_30, lng + hor_angular_distance_of_30],
            [lat - vert_angular_distance_of_30, lng - hor_angular_distance_of_30],
            [lat + vert_angular_distance_of_30, lng - hor_angular_distance_of_30],
        ]

        vert_angular_distance_of_60 = vert_angular_distance * Math.sqrt(3)/2
        hor_angular_distance_of_60 = hor_angular_distance / 2
        all_60_points = [
            [lat + vert_angular_distance_of_60, lng + hor_angular_distance_of_60],
            [lat - vert_angular_distance_of_60, lng + hor_angular_distance_of_60],
            [lat - vert_angular_distance_of_60, lng - hor_angular_distance_of_60],
            [lat + vert_angular_distance_of_60, lng - hor_angular_distance_of_60],
        ]
        all_30_points + all_60_points
    end

    def get_15_75_points(lat, lng, vert_angular_distance, hor_angular_distance)
        vert_angular_distance_of_15 = vert_angular_distance * SIN15
        hor_angular_distance_of_15 = hor_angular_distance * COS15
        p "SIN 15!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        p SIN15
        p COS15
        p "SIN 75!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        p SIN75
        p COS75
        all_15_points = [
            [lat + vert_angular_distance_of_15, lng + hor_angular_distance_of_15],
            [lat - vert_angular_distance_of_15, lng + hor_angular_distance_of_15],
            [lat - vert_angular_distance_of_15, lng - hor_angular_distance_of_15],
            [lat + vert_angular_distance_of_15, lng - hor_angular_distance_of_15],
        ]

        vert_angular_distance_of_75 = vert_angular_distance * SIN75
        hor_angular_distance_of_75 = hor_angular_distance * COS75
        all_75_points = [
            [lat + vert_angular_distance_of_75, lng + hor_angular_distance_of_75],
            [lat - vert_angular_distance_of_75, lng + hor_angular_distance_of_75],
            [lat - vert_angular_distance_of_75, lng - hor_angular_distance_of_75],
            [lat + vert_angular_distance_of_75, lng - hor_angular_distance_of_75],
        ]
        all_15_points + all_75_points
    end

    def get_distance(lat1, lng1, lat2, lng2)
        vert_angle_difference = (lat1 - lat2).abs
        vert_angle_difference_radians = vert_angle_difference * Math::PI / 180
        vert_distance = RADIUS_OF_EARTH * vert_angle_difference_radians

        hor_angular_distance = (lng1 - lng2).abs
        hor_angular_distance_radians = hor_angular_distance * Math::PI / 180

        average_lat = (lat1 + lat2)/ 2
        average_lat_radians = average_lat * Math::PI / 180
        radius_at_latitude = RADIUS_OF_EARTH * Math.cos(average_lat_radians)
        hor_distance = radius_at_latitude * hor_angular_distance_radians

        Math.sqrt(vert_distance**2 + hor_distance**2)
    end

    def get_midpoint(point1, point2)
        [(point1[0] + point2[0])/2, (point1[1] + point2[1])/2]
    end

    def get_closest_points(equidistant_points1, equidistant_points2)
        smallest_distance = 10000
        closest_points = []
        equidistant_points1.each do |point1|
            equidistant_points2.each do |point2|
                distance = get_distance(point1[0], point1[1], point2[0], point2[1])
                                    p "-----------"
                    p "#{point1} is #{distance} from #{point2}"
                if distance < smallest_distance
                    smallest_distance = distance
                    closest_points = [point1, point2]
                end
            end
        end
        closest_points
    end
end